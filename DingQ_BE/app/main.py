import io
import json
import logging
import os
import tempfile
import time
import uuid
from datetime import datetime
from typing import Any, Dict, List

import uvicorn
from fastapi import Depends, FastAPI, File, Form, HTTPException, Query, Request, UploadFile, Security
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from PIL import Image
from google.cloud import storage
try:
    from google.cloud import secretmanager
    SECRETMANAGER_AVAILABLE = True
except ImportError:
    secretmanager = None
    SECRETMANAGER_AVAILABLE = False
# SQLAlchemy imports removed for simplicity

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

from model.clip_search import CLIPImageSearcher
from model.generate_icon import generate_with_retries

# Import database and models (simplified for deployment)
try:
    from database import create_tables
    DATABASE_AVAILABLE = True
except ImportError:
    DATABASE_AVAILABLE = False
    def create_tables():
        """Dummy function when database is not available"""
        pass

# Security middleware removed for simplicity

app = FastAPI(
    title="DingQ Image Search & Generation API",
    description="CLIP 기반 이미지 유사도 검색 및 Gemini AI 기반 아이콘 생성 API with PostgreSQL 연동",
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

# Google Cloud Storage 설정
GCS_BUCKET_NAME = os.getenv("GCS_BUCKET_NAME", "dingq-generated-icons")
GCS_CREDENTIALS_PATH = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")

# Google Cloud Project ID for Secret Manager
PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT", "your-project-id")

def get_secret(secret_name: str, version: str = "latest") -> str:
    """
    Google Cloud Secret Manager에서 시크릿 값 조회
    
    Args:
        secret_name: 시크릿 이름
        version: 시크릿 버전 (기본값: latest)
    
    Returns:
        str: 시크릿 값 (실패시 빈 문자열)
    """
    # Secret Manager 패키지가 없으면 환경변수 사용
    if secretmanager is None:
        logger.warning(f"⚠️ Secret Manager 패키지가 없습니다. 환경변수 사용: {secret_name}")
        return os.getenv(secret_name, "")
    
    try:
        # Secret Manager 클라이언트 생성
        client = secretmanager.SecretManagerServiceClient()
        
        # 시크릿 경로 구성
        secret_path = f"projects/{PROJECT_ID}/secrets/{secret_name}/versions/{version}"
        
        # 시크릿 값 조회
        response = client.access_secret_version(request={"name": secret_path})
        secret_value = response.payload.data.decode("UTF-8")
        
        logger.info(f"✅ Secret Manager에서 시크릿 조회 성공: {secret_name}")
        return secret_value
        
    except Exception as e:
        logger.warning(f"⚠️ Secret Manager 시크릿 조회 실패 ({secret_name}): {e}")
        # 개발 환경에서는 환경변수 사용
        return os.getenv(secret_name, "")

def initialize_secrets():
    """
    서버 시작시 필요한 시크릿들을 Secret Manager에서 로드
    """
    global GOOGLE_API_KEY
    
    # 프로덕션 환경에서는 Secret Manager 사용
    if os.getenv("ENVIRONMENT") == "production":
        logger.info("🔐 프로덕션 환경: Secret Manager에서 시크릿 로드 중...")
        GOOGLE_API_KEY = get_secret("gemini-api-key")
        
        if not GOOGLE_API_KEY:
            logger.error("❌ Gemini API 키를 Secret Manager에서 가져올 수 없습니다!")
        else:
            # API 키에서 공백과 개행문자 제거
            GOOGLE_API_KEY = GOOGLE_API_KEY.strip()
            # 환경변수로 설정하여 generate_icon.py에서 사용할 수 있도록 함
            os.environ["GOOGLE_API_KEY"] = GOOGLE_API_KEY
            logger.info(f"✅ Gemini API 키 환경변수 설정 완료 (길이: {len(GOOGLE_API_KEY)}자)")
            
    else:
        # 개발 환경에서는 환경변수 사용
        logger.info("🔧 개발 환경: 환경변수에서 시크릿 로드 중...")
        GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY", "")
        
        if not GOOGLE_API_KEY:
            logger.warning("⚠️ GOOGLE_API_KEY 환경변수가 설정되지 않았습니다!")

# 전역 변수
GOOGLE_API_KEY = ""

def get_gcs_client():
    """Google Cloud Storage 클라이언트 생성"""
    try:
        if GCS_CREDENTIALS_PATH and os.path.exists(GCS_CREDENTIALS_PATH):
            client = storage.Client.from_service_account_json(GCS_CREDENTIALS_PATH)
        else:
            # 환경 변수가 설정되어 있거나 GCP 환경에서 실행 중인 경우
            client = storage.Client()
        return client
    except Exception as e:
        logger.warning(f"GCS 클라이언트 생성 실패: {e}")
        return None

def upload_to_gcs(image_bytes: bytes, filename: str, content_type: str = "image/png") -> str:
    """
    이미지를 Google Cloud Storage에 업로드
    
    Args:
        image_bytes: 이미지 바이트 데이터
        filename: 저장할 파일명
        content_type: 파일 MIME 타입
    
    Returns:
        str: 업로드된 파일의 공개 URL (실패시 빈 문자열)
    """
    try:
        client = get_gcs_client()
        if not client:
            logger.warning("GCS 클라이언트를 사용할 수 없습니다.")
            return ""
        
        bucket = client.bucket(GCS_BUCKET_NAME)
        blob = bucket.blob(filename)
        
        # 이미지 업로드
        blob.upload_from_string(image_bytes, content_type=content_type)
        
        # 공개 읽기 권한 설정
        blob.make_public()
        
        # 공개 URL 반환
        public_url = blob.public_url
        logger.info(f"GCS 업로드 성공: {filename} -> {public_url}")
        return public_url
        
    except Exception as e:
        logger.error(f"GCS 업로드 실패 ({filename}): {e}")
        return ""

def list_gcs_images(prefix: str = "", limit: int = 100) -> List[Dict]:
    """
    Google Cloud Storage에서 이미지 목록 조회
    
    Args:
        prefix: 파일명 접두사 필터
        limit: 최대 조회 개수
    
    Returns:
        List[Dict]: 이미지 정보 리스트
    """
    try:
        client = get_gcs_client()
        if not client:
            logger.warning("GCS 클라이언트를 사용할 수 없습니다.")
            return []
        
        bucket = client.bucket(GCS_BUCKET_NAME)
        # 충분한 개수를 가져온 후 API 레벨에서 정렬 및 제한
        # 최대 10000개까지 조회해서 최신 파일들을 놓치지 않도록 함
        max_fetch = max(limit * 10, 1000) if limit < 1000 else 10000
        blobs = bucket.list_blobs(prefix=prefix, max_results=max_fetch)
        
        images = []
        for blob in blobs:
            # 이미지 파일만 필터링
            if blob.name.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp')):
                images.append({
                    "filename": blob.name,
                    "url": blob.public_url,
                    "size": blob.size,
                    "created": blob.time_created.isoformat() if blob.time_created else None,
                    "updated": blob.updated.isoformat() if blob.updated else None,
                })
        
        return images
        
    except Exception as e:
        logger.error(f"GCS 이미지 목록 조회 실패: {e}")
        return []


@app.on_event("startup")
async def startup_event():
    """서버 시작시 CLIP 모델 초기화 및 데이터베이스 테이블 생성"""
    global clip_searcher
    logger.info("🚀 서버 시작: CLIP 모델 로딩 및 데이터베이스 초기화 중...")
    
    # 1️⃣ 시크릿 초기화 (Secret Manager 또는 환경변수)
    initialize_secrets()

    # 데이터베이스 초기화 (선택적)
    try:
        create_tables()
        logger.info("✅ 데이터베이스 테이블 생성 완료")
    except Exception as db_error:
        logger.warning(f"⚠️ 데이터베이스 연결 실패 (계속 진행): {db_error}")
        logger.info("📝 데이터베이스 없이 CLIP 모델만 로딩합니다")

    # CLIP 모델 초기화 (필수)
    try:
        # 벡터 가중치 파일 경로 (환경변수로 재정의 가능)
        reference_data_path = os.getenv("VECTOR_WEIGHT_PATH", "model/vectorweight.npz")

        if not os.path.exists(reference_data_path):
            raise FileNotFoundError(f"벡터 파일을 찾을 수 없습니다: {reference_data_path}")

        # CLIP 검색기 초기화 (1분 정도 소요)
        clip_searcher = CLIPImageSearcher(reference_data_path)
        logger.info("✅ CLIP 모델 로딩 완료! 서버 준비됨")

    except Exception as e:
        logger.error(f"❌ CLIP 모델 로딩 실패: {e}")
        clip_searcher = None


@app.get("/")
def read_root():
    """서버 상태 확인"""
    model_status = "loaded" if clip_searcher is not None else "not_loaded"
    gcs_client = get_gcs_client()
    gcs_status = "connected" if gcs_client else "disconnected"
    
    return {
        "message": "DingQ Image Search & Generation API",
        "status": "running",
        "model_status": model_status,
        "gcs_status": gcs_status,
        "gcs_bucket": GCS_BUCKET_NAME,
        "features": [
            "CLIP search (Top-100)", 
            "Icon generation (Gemini AI)", 
            "Google Cloud Storage integration",
            "Image gallery & management",
            "PostgreSQL integration", 
            "Sketch storage"
        ],
        "endpoints": {
            "search": "POST /search - 이미지 유사도 검색",
            "generate": "POST /generate - 아이콘 생성 (GCS 자동 저장)",
            "images": "GET /images - GCS 이미지 목록 조회",
            "recent_images": "GET /images/recent - 최근 생성 이미지"
        }
    }


@app.get("/health")
def health_check():
    """헬스체크"""
    model_ready = clip_searcher is not None
    
    # 데이터베이스 기능 임시 비활성화
    db_status = "disabled"
    
    return {
        "status": "healthy" if model_ready else "model_not_ready",
        "model_loaded": model_ready,
        "database": db_status,
    }


# Auth status endpoint removed for simplicity


@app.post("/search")
async def search_similar_images(
    request: Request, 
    image: UploadFile = File(...)
):
    """
    이미지 유사도 검색 API with PostgreSQL 스케치 저장

    Args:
        image: 업로드할 이미지 파일
        db: 데이터베이스 세션

    Returns:
        JSON: Top-100 유사 이미지 결과
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

        # CLIP 모델로 유사도 검색 (Top-100)
        result_json = clip_searcher.search_similarity(temp_image_path, top_k=100)
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
        top100_results = []
        for result in result_data.get("results", []):
            top100_results.append(
                {
                    "label": result["reference_name"],
                    "score": round(result["similarity_score"], 4),
                    "url": f"https://storage.googleapis.com/dingq-svg-icons/{result['reference_name']}.svg",
                }
            )

        # 검색 결과 구성
        search_results = {
            "top100": top100_results,
            "processing_time": time.time() - start_time,
            "total_results": len(result_data.get("results", [])),
        }

        # 데이터베이스 저장 기능 임시 비활성화
        logger.info(f"검색 요청 처리 완료 - IP: {user_ip}, 파일: {image.filename}")
        # 향후 데이터베이스 연결 시 스케치 저장 기능 활성화 예정

        process_time = time.time() - start_time
        logger.info(f"검색 완료: {len(top100_results)}개 결과, 처리시간: {process_time:.3f}초")

        return search_results

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"검색 중 예상치 못한 오류: {e}")
        raise HTTPException(status_code=500, detail=f"서버 오류: {str(e)}")


@app.get("/sketches/{user_ip}")
async def get_user_sketches(
    user_ip: str, 
    limit: int = 10
):
    """
    사용자 스케치 히스토리 조회 (데이터베이스 없이 임시 비활성화)
    """
    return {
        "message": "Sketch history feature is temporarily disabled",
        "user_ip": user_ip,
        "total_sketches": 0,
        "sketches": [],
    }


@app.get("/stats")
async def get_stats():
    """
    서비스 통계 조회 (데이터베이스 없이 임시 비활성화)
    """
    return {
        "message": "Statistics feature is temporarily disabled",
        "total_sketches": 0,
        "unique_users": 0,
        "model_status": "loaded" if clip_searcher else "not_loaded",
    }


@app.post("/generate")
async def generate_icon_api(
    request: Request,
    description: str = Form(..., description="아이콘 설명 텍스트"),
    image: UploadFile = File(..., description="사용자가 그린 손그림 이미지"),
    temperature: float = Form(0.5, description="생성 모델 temperature (0.0-1.0)"),
    target_count: int = Form(5, description="생성할 아이콘 개수 (1-10)")
):
    """
    손그림을 픽토그램으로 변환하는 API
    
    Args:
        description: 아이콘에 대한 텍스트 설명
        image: 사용자가 그린 손그림 이미지
        temperature: 생성 모델의 창의성 조절 (0.0-1.0)
        target_count: 생성할 아이콘 개수 (1-10)
    
    Returns:
        JSON: 생성된 아이콘들의 base64 인코딩 결과
    """
    import base64
    
    start_time = time.time()
    
    # 입력 검증
    if not image.content_type or not image.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="이미지 파일만 업로드 가능합니다.")
    
    if not (0.0 <= temperature <= 1.0):
        raise HTTPException(status_code=400, detail="temperature는 0.0과 1.0 사이의 값이어야 합니다.")
    
    if not (1 <= target_count <= 10):
        raise HTTPException(status_code=400, detail="target_count는 1과 10 사이의 값이어야 합니다.")
    
    if len(description.strip()) == 0:
        raise HTTPException(status_code=400, detail="설명 텍스트를 입력해주세요.")
    
    try:
        # 이미지 읽기 및 PIL 변환
        image_data = await image.read()
        pil_image = Image.open(io.BytesIO(image_data))
        
        # 사용자 IP 추출
        user_ip = request.client.host if request.client else "unknown"
        
        logger.info(
            f"아이콘 생성 요청: 설명='{description}', 이미지={image.filename}, "
            f"온도={temperature}, 개수={target_count}, IP={user_ip}"
        )
        
        # 아이콘 생성 (generate_with_retries 함수 사용)
        generated_images = generate_with_retries(
            input_text=description,
            input_image=pil_image,
            temperature=temperature,
            target_count=target_count,
            max_retries=3
        )
        
        # 생성된 이미지들을 base64로 인코딩 및 GCS에 업로드
        results = []
        session_id = str(uuid.uuid4())[:8]  # 세션 고유 ID
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        for i, img_bytes in enumerate(generated_images):
            img_bytes.seek(0)  # BytesIO 포인터를 처음으로 이동
            image_data = img_bytes.read()
            
            # Base64 인코딩 (사용자 응답용)
            base64_data = base64.b64encode(image_data).decode('utf-8')
            
            # GCS 업로드용 파일명 생성
            safe_description = "".join(c if c.isalnum() or c in '-_' else '_' for c in description[:20])
            filename = f"generated/{timestamp}_{session_id}_{safe_description}_{i+1}.png"
            
            # Google Cloud Storage에 업로드
            gcs_url = upload_to_gcs(image_data, filename, "image/png")
            
            result_item = {
                "id": i + 1,
                "image_base64": base64_data,
                "format": "PNG",
                "filename": filename,
                "gcs_url": gcs_url if gcs_url else None,
                "gcs_uploaded": bool(gcs_url)
            }
            results.append(result_item)
        
        processing_time = time.time() - start_time
        
        # GCS 업로드 통계
        gcs_uploaded_count = sum(1 for r in results if r["gcs_uploaded"])
        
        response_data = {
            "success": True,
            "description": description,
            "generated_count": len(results),
            "requested_count": target_count,
            "processing_time": processing_time,
            "temperature": temperature,
            "session_id": session_id,
            "gcs_uploaded_count": gcs_uploaded_count,
            "gcs_bucket": GCS_BUCKET_NAME,
            "results": results
        }
        
        logger.info(
            f"아이콘 생성 완료: {len(results)}개 생성, 처리시간: {processing_time:.3f}초, IP: {user_ip}"
        )
        
        return response_data
        
    except Exception as e:
        logger.error(f"아이콘 생성 중 오류: {e}")
        raise HTTPException(status_code=500, detail=f"아이콘 생성 실패: {str(e)}")


@app.get("/images")
async def get_gcs_images(
    prefix: str = Query("", description="파일명 접두사 필터 (예: 'generated/', 'user_uploads/')"),
    limit: int = Query(100, description="최대 조회 개수 (1-1000)", ge=1, le=1000),
    sort_by: str = Query("created", description="정렬 기준 (created, filename, size)"),
    order: str = Query("desc", description="정렬 순서 (asc, desc)")
):
    """
    Google Cloud Storage에 저장된 이미지 목록 조회 API
    
    Args:
        prefix: 파일명 접두사 필터 (폴더별 필터링 가능)
        limit: 최대 조회 개수
        sort_by: 정렬 기준 (created, filename, size)
        order: 정렬 순서 (asc, desc)
    
    Returns:
        JSON: 이미지 목록과 메타데이터
    """
    try:
        # GCS에서 이미지 목록 조회 (더 많은 개수를 가져옴)
        images = list_gcs_images(prefix=prefix, limit=limit)
        
        # 정렬 처리
        reverse_order = (order.lower() == "desc")
        
        if sort_by == "created":
            images.sort(key=lambda x: x.get("created", ""), reverse=reverse_order)
        elif sort_by == "filename":
            images.sort(key=lambda x: x.get("filename", ""), reverse=reverse_order)
        elif sort_by == "size":
            images.sort(key=lambda x: x.get("size", 0), reverse=reverse_order)
        
        # 정렬 후 최종 제한
        images = images[:limit]
        
        # 응답 데이터 구성
        response_data = {
            "success": True,
            "total_count": len(images),
            "limit": limit,
            "prefix": prefix,
            "sort_by": sort_by,
            "order": order,
            "bucket_name": GCS_BUCKET_NAME,
            "images": images,
            "usage_note": "프론트엔드에서 각 이미지의 'url' 필드를 사용하여 직접 접근 가능합니다."
        }
        
        logger.info(f"GCS 이미지 목록 조회: {len(images)}개 이미지, prefix='{prefix}'")
        return response_data
        
    except Exception as e:
        logger.error(f"GCS 이미지 목록 조회 실패: {e}")
        raise HTTPException(status_code=500, detail=f"이미지 목록 조회 실패: {str(e)}")


@app.get("/images/recent")
async def get_recent_generated_images(
    days: int = Query(7, description="최근 N일 이내 생성된 이미지 조회", ge=1, le=365),
    limit: int = Query(50, description="최대 조회 개수", ge=1, le=500)
):
    """
    최근 생성된 아이콘 이미지 목록 조회 API
    
    Args:
        days: 최근 N일 이내
        limit: 최대 조회 개수
    
    Returns:
        JSON: 최근 생성된 이미지 목록
    """
    try:
        # 'generated/' 폴더의 이미지만 조회
        all_images = list_gcs_images(prefix="generated/", limit=limit * 2)
        
        # 최근 N일 필터링
        from datetime import datetime, timedelta
        cutoff_date = datetime.now() - timedelta(days=days)
        
        recent_images = []
        for img in all_images:
            if img.get("created"):
                created_date = datetime.fromisoformat(img["created"].replace('Z', '+00:00'))
                if created_date.replace(tzinfo=None) >= cutoff_date:
                    recent_images.append(img)
        
        # 최신순 정렬 및 제한
        recent_images.sort(key=lambda x: x.get("created", ""), reverse=True)
        recent_images = recent_images[:limit]
        
        response_data = {
            "success": True,
            "total_count": len(recent_images),
            "days": days,
            "limit": limit,
            "bucket_name": GCS_BUCKET_NAME,
            "images": recent_images
        }
        
        logger.info(f"최근 {days}일 이미지 조회: {len(recent_images)}개")
        return response_data
        
    except Exception as e:
        logger.error(f"최근 이미지 조회 실패: {e}")
        raise HTTPException(status_code=500, detail=f"최근 이미지 조회 실패: {str(e)}")


@app.get("/proxy/image/{filename:path}")
@app.options("/proxy/image/{filename:path}")
async def proxy_gcs_image(filename: str, request: Request):
    """
    GCS 이미지 프록시 엔드포인트 - CORS 헤더 포함
    
    Args:
        filename: GCS 버킷 내 파일 경로 (예: generated/20250709_005259_5d1a9794_happy_2.png)
    
    Returns:
        이미지 파일 (CORS 헤더 포함)
    """
    # CORS 헤더 설정
    headers = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, OPTIONS",
        "Access-Control-Allow-Headers": "*",
        "Access-Control-Max-Age": "3600"
    }
    
    # OPTIONS 요청 처리 (CORS preflight)
    if request.method == "OPTIONS":
        from fastapi.responses import Response
        return Response(
            content="",
            headers=headers
        )
    
    try:
        # GCS에서 이미지 다운로드
        gcs_client = get_gcs_client()
        if not gcs_client:
            raise HTTPException(status_code=500, detail="GCS 클라이언트 초기화 실패")
        
        bucket = gcs_client.bucket(GCS_BUCKET_NAME)
        blob = bucket.blob(filename)
        
        # 파일 존재 확인
        if not blob.exists():
            raise HTTPException(status_code=404, detail="이미지를 찾을 수 없습니다")
        
        # 이미지 데이터 다운로드
        image_data = blob.download_as_bytes()
        
        # 콘텐츠 타입 결정
        content_type = blob.content_type or "image/png"
        
        # 캐시 헤더 추가
        headers["Cache-Control"] = "public, max-age=3600"
        
        # CORS 헤더 포함한 응답 생성
        from fastapi.responses import Response
        
        return Response(
            content=image_data,
            media_type=content_type,
            headers=headers
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"이미지 프록시 오류: {e}")
        raise HTTPException(status_code=500, detail="이미지 로드 실패")


@app.options("/proxy/image/{filename:path}")
async def proxy_gcs_image_options(filename: str):
    """
    CORS preflight 요청 처리
    """
    headers = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, OPTIONS",
        "Access-Control-Allow-Headers": "*",
        "Access-Control-Max-Age": "86400"
    }
    
    from fastapi.responses import Response
    return Response(headers=headers)


if __name__ == "__main__":
    # Cloud Run에서는 PORT 환경변수 사용, 로컬에서는 8000
    port = int(os.getenv("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=False)
