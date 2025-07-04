import io
import json
import logging
import os
import tempfile
import time
from typing import Any, Dict, List

import uvicorn
from fastapi import Depends, FastAPI, File, HTTPException, Request, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from PIL import Image
from sqlalchemy.orm import Session

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

from model.clip_search import CLIPImageSearcher

# Import database and models
from database import UserSketch, create_tables, get_db, save_user_sketch

app = FastAPI(
    title="DingQ Image Search API",
    description="CLIP 기반 이미지 유사도 검색 API with PostgreSQL 연동",
    version="1.0.0",
)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 프론트엔드 도메인으로 제한 권장
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 전역 CLIP 검색기 (서버 시작시 한 번만 로드)
clip_searcher = None


@app.on_event("startup")
async def startup_event():
    """서버 시작시 CLIP 모델 초기화 및 데이터베이스 테이블 생성"""
    global clip_searcher
    logger.info("🚀 서버 시작: CLIP 모델 로딩 및 데이터베이스 초기화 중...")

    try:
        # 데이터베이스 테이블 생성
        create_tables()
        logger.info("✅ 데이터베이스 테이블 생성 완료")

        # 벡터 가중치 파일 경로 (환경변수로 재정의 가능)
        reference_data_path = os.getenv("VECTOR_WEIGHT_PATH", "model/vectorweight.npz")

        if not os.path.exists(reference_data_path):
            raise FileNotFoundError(f"벡터 파일을 찾을 수 없습니다: {reference_data_path}")

        # CLIP 검색기 초기화 (1분 정도 소요)
        clip_searcher = CLIPImageSearcher(reference_data_path)
        logger.info("✅ CLIP 모델 로딩 완료! 서버 준비됨")

    except Exception as e:
        logger.error(f"❌ 서버 초기화 실패: {e}")
        clip_searcher = None


@app.get("/")
def read_root():
    """서버 상태 확인"""
    model_status = "loaded" if clip_searcher is not None else "not_loaded"
    return {
        "message": "DingQ Image Search API",
        "status": "running",
        "model_status": model_status,
        "features": ["CLIP search", "PostgreSQL integration", "Sketch storage"],
    }


@app.get("/health")
def health_check():
    """헬스체크"""
    model_ready = clip_searcher is not None
    return {
        "status": "healthy" if model_ready else "model_not_ready",
        "model_loaded": model_ready,
        "database": "connected",
    }


@app.post("/search")
async def search_similar_images(
    request: Request, image: UploadFile = File(...), db: Session = Depends(get_db)
):
    """
    이미지 유사도 검색 API with PostgreSQL 스케치 저장

    Args:
        image: 업로드할 이미지 파일
        db: 데이터베이스 세션

    Returns:
        JSON: Top-5 유사 이미지 결과
    """
    start_time = time.time()

    # 모델 로딩 상태 확인
    if clip_searcher is None:
        raise HTTPException(
            status_code=503, detail="CLIP 모델이 아직 로딩되지 않았습니다. 잠시 후 다시 시도해주세요."
        )

    # 이미지 파일 검증
    if not image.content_type or not image.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="이미지 파일만 업로드 가능합니다.")

    try:
        # 이미지 읽기 및 PIL 변환
        image_data = await image.read()
        pil_image = Image.open(io.BytesIO(image_data))

        # 사용자 IP 추출
        user_ip = request.client.host if request.client else "unknown"

        logger.info(
            f"이미지 수신: {image.filename}, 크기: {len(image_data)} bytes, IP: {user_ip}"
        )

        # 임시 파일로 저장 (CLIP 검색기가 파일 경로를 요구)
        with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as temp_file:
            pil_image.save(temp_file.name, "PNG")
            temp_image_path = temp_file.name

        # CLIP 모델로 유사도 검색 (Top-5)
        result_json = clip_searcher.search_similarity(temp_image_path, top_k=5)
        result_data = json.loads(result_json)

        # 임시 파일 삭제
        os.unlink(temp_image_path)

        # 에러 체크
        if "error" in result_data:
            logger.error(f"CLIP 검색 에러: {result_data['error']}")
            raise HTTPException(
                status_code=500, detail=f"검색 중 오류 발생: {result_data['error']}"
            )

        # 응답 포맷 변환
        top5_results = []
        for result in result_data.get("results", [])[:5]:
            top5_results.append(
                {
                    "label": result["reference_name"],
                    "score": round(result["similarity_score"], 4),
                    "url": f"https://storage.googleapis.com/dingq-svg-icons/{result['reference_name']}.svg",
                }
            )

        # 검색 결과 구성
        search_results = {
            "top5": top5_results,
            "processing_time": time.time() - start_time,
            "total_results": len(result_data.get("results", [])),
        }

        # PostgreSQL에 사용자 스케치 저장
        try:
            saved_sketch = save_user_sketch(
                db=db,
                user_ip=user_ip,
                sketch_data=image_data,
                original_filename=image.filename or "unknown",
                content_type=image.content_type,
                file_size=len(image_data),
                search_results=search_results,
            )
            logger.info(f"사용자 스케치 저장 완료: ID {saved_sketch.id}")
        except Exception as db_error:
            logger.error(f"데이터베이스 저장 에러: {db_error}")
            # 데이터베이스 에러가 있어도 검색 결과는 반환

        process_time = time.time() - start_time
        logger.info(f"검색 완료: {len(top5_results)}개 결과, 처리시간: {process_time:.3f}초")

        return search_results

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"검색 중 예상치 못한 오류: {e}")
        raise HTTPException(status_code=500, detail=f"서버 오류: {str(e)}")


@app.get("/sketches/{user_ip}")
async def get_user_sketches(
    user_ip: str, limit: int = 10, db: Session = Depends(get_db)
):
    """
    사용자 스케치 히스토리 조회

    Args:
        user_ip: 사용자 IP 주소
        limit: 조회할 스케치 개수 (기본값: 10)
        db: 데이터베이스 세션

    Returns:
        JSON: 사용자 스케치 히스토리
    """
    try:
        sketches = (
            db.query(UserSketch)
            .filter(UserSketch.user_ip == user_ip)
            .order_by(UserSketch.created_at.desc())
            .limit(limit)
            .all()
        )

        sketch_history = []
        for sketch in sketches:
            sketch_history.append(
                {
                    "id": sketch.id,
                    "filename": sketch.original_filename,
                    "file_size": sketch.file_size,
                    "created_at": sketch.created_at.isoformat(),
                    "search_results": sketch.search_results,
                }
            )

        return {
            "user_ip": user_ip,
            "total_sketches": len(sketch_history),
            "sketches": sketch_history,
        }

    except Exception as e:
        logger.error(f"스케치 히스토리 조회 오류: {e}")
        raise HTTPException(status_code=500, detail=f"히스토리 조회 실패: {str(e)}")


@app.get("/stats")
async def get_stats(db: Session = Depends(get_db)):
    """
    서비스 통계 조회

    Returns:
        JSON: 서비스 이용 통계
    """
    try:
        total_sketches = db.query(UserSketch).count()
        unique_users = db.query(UserSketch.user_ip).distinct().count()

        return {
            "total_sketches": total_sketches,
            "unique_users": unique_users,
            "model_status": "loaded" if clip_searcher else "not_loaded",
        }

    except Exception as e:
        logger.error(f"통계 조회 오류: {e}")
        raise HTTPException(status_code=500, detail=f"통계 조회 실패: {str(e)}")


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
