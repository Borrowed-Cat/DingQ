# DingQ Backend API

스케치 이미지 기반 유사 이미지 검색 서비스의 백엔드 API

## 🚀 기능

- **일반 검색**: 스케치 이미지를 받아 유사한 SVG 아이콘 검색
- **딥 검색**: GPT를 활용한 이미지 개선 후 검색
- **벡터 유사도 검색**: PostgreSQL + pgvector를 활용한 고성능 검색
- **로깅 및 모니터링**: 요청/응답 시간 및 에러 추적

## 📋 요구사항

- Python 3.11+
- PostgreSQL 14+ (pgvector 확장 필요)
- Docker (배포용)
- Google Cloud Platform 계정 (배포용)

## 🛠️ 로컬 개발 환경 설정

### 1. 저장소 클론
```bash
git clone <repository-url>
cd DingQ_BE
```

### 2. 가상환경 생성 및 활성화
```bash
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
```

### 3. 의존성 설치
```bash
pip install -r requirements.txt
```

### 4. 환경 변수 설정
```bash
cp env.example .env
# .env 파일을 편집하여 실제 값으로 설정
```

### 5. PostgreSQL 설정
```bash
# PostgreSQL 설치 후 pgvector 확장 설치
psql -d your_database -f database/schema.sql
```

### 6. 서버 실행
```bash
cd app
uvicorn main:app --reload
```

## 🌐 API 엔드포인트

### 기본 엔드포인트
- `GET /` - 서버 상태 확인
- `GET /health` - 헬스 체크

### 검색 엔드포인트
- `POST /api/search/normal` - 일반 검색
- `POST /api/search/deep` - 딥 검색 (GPT 활용)
- `POST /api/upload/sketch` - 스케치 업로드 (테스트용)

### API 문서
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## 🐳 Docker 실행

### 로컬 Docker 실행
```bash
docker build -t dingq-backend .
docker run -p 8000:8000 dingq-backend
```

## ☁️ GCP 배포

### 1. 사전 준비
```bash
# gcloud CLI 설치 및 인증
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### 2. 자동 배포
```bash
chmod +x deploy.sh
./deploy.sh
```

### 3. 수동 배포
```bash
# Docker 이미지 빌드 및 푸시
docker build -t gcr.io/YOUR_PROJECT_ID/dingq-backend .
docker push gcr.io/YOUR_PROJECT_ID/dingq-backend

# Cloud Run 배포
gcloud run deploy dingq-backend \
  --image gcr.io/YOUR_PROJECT_ID/dingq-backend \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

## 📊 모니터링

### 로그 확인
```bash
# Cloud Run 로그
gcloud logs read --service=dingq-backend --limit=50

# 로컬 로그
tail -f app.log
```

### 성능 메트릭
- API 응답 시간
- 요청/응답 로그
- 에러율 추적

## 🔧 개발 가이드

### 새로운 엔드포인트 추가
1. `app/main.py`에 새로운 라우트 추가
2. 로깅 추가
3. 에러 처리 구현
4. API 문서 업데이트

### 데이터베이스 스키마 변경
1. `database/schema.sql` 수정
2. 마이그레이션 스크립트 작성
3. `app/database.py` 업데이트

## 🤝 팀 협업

### 프론트엔드 개발자
- API 스펙: `http://localhost:8000/docs`
- CORS 설정: 모든 도메인 허용 (개발용)
- 응답 형식: JSON

### ML 개발자
- `app/model/inference.py` 구현 필요
- 함수 시그니처:
  - `async def process_image(image, *args, **kwargs)`
  - `async def refine_image_with_gpt(image, *args, **kwargs)`
  - `async def search_similar_images(image, top_n, mode="normal", *args, **kwargs)`

## 📝 TODO

- [ ] 실제 ML 모델 연동
- [ ] 벡터 DB 최적화
- [ ] 캐싱 구현
- [ ] 인증/인가 추가
- [ ] API 버전 관리
- [ ] 테스트 코드 작성

## 📞 문의

백엔드 관련 문의사항은 백엔드 개발팀에 연락해주세요. 