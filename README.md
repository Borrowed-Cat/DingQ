# DingQ - AI 기반 이미지 검색 시스템

CLIP 모델을 활용한 스케치 이미지 유사도 검색 시스템입니다. 사용자가 업로드한 손 스케치를 기반으로 유사한 SVG 아이콘을 찾아주며, PostgreSQL을 통해 사용자 스케치를 저장하여 모델 성능 개선에 활용합니다.

## 🚀 주요 기능

- **CLIP 기반 이미지 검색**: OpenAI CLIP 모델을 사용한 의미적 이미지 유사도 검색
- **PostgreSQL 연동**: 사용자 스케치 자동 저장으로 ML 모델 성능 개선 데이터 수집
- **FastAPI 백엔드**: 고성능 비동기 API 서버
- **도커 컨테이너화**: 환경 일관성을 위한 완전한 도커 지원
- **실시간 모니터링**: 헬스체크 및 서비스 통계 제공

## 📋 시스템 요구사항

- Docker & Docker Compose
- Python 3.11+
- PyTorch 2.7+
- PostgreSQL 15+ (pgvector 확장)

## 🛠️ 설치 및 실행

### 1. 환경 설정

```bash
# 레포지토리 클론
git clone <repository-url>
cd DingQ

# 환경 변수 설정
cp DingQ_BE/env.example DingQ_BE/.env
```

### 2. Docker Compose로 실행

```bash
# 전체 시스템 실행 (PostgreSQL + FastAPI)
docker-compose up -d

# 로그 확인
docker-compose logs -f backend
```

### 3. 서비스 확인

```bash
# 헬스체크
curl http://localhost:8000/health

# API 문서 확인
open http://localhost:8000/docs
```

## 🔧 API 엔드포인트

### 기본 엔드포인트

- `GET /` - 서비스 상태 확인
- `GET /health` - 헬스체크
- `GET /docs` - API 문서 (Swagger UI)

### 이미지 검색

- `POST /search` - 이미지 업로드 및 유사도 검색
  ```bash
  curl -X POST "http://localhost:8000/search" \
    -F "image=@your_sketch.png"
  ```

### 데이터 조회

- `GET /sketches/{user_ip}` - 사용자 스케치 히스토리
- `GET /stats` - 서비스 이용 통계

## 🗄️ 데이터베이스 스키마

### user_sketches 테이블
```sql
CREATE TABLE user_sketches (
    id SERIAL PRIMARY KEY,
    user_ip VARCHAR(45),
    sketch_data BYTEA NOT NULL,
    original_filename VARCHAR(255),
    content_type VARCHAR(100),
    file_size INTEGER,
    search_results JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP
);
```

### svg_icons 테이블
```sql
CREATE TABLE svg_icons (
    id SERIAL PRIMARY KEY,
    icon_name VARCHAR(255) NOT NULL,
    svg_path VARCHAR(500) NOT NULL,
    vector_features vector(512),
    category VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🧪 테스트

### API 테스트 실행

```bash
# 테스트 스크립트 실행
cd DingQ_BE
python test_search_api.py
```

### 개별 테스트

```bash
# 헬스체크 테스트
curl http://localhost:8000/health

# 이미지 검색 테스트
curl -X POST "http://localhost:8000/search" \
  -F "image=@../testImages/sketch_1.png"

# 통계 확인
curl http://localhost:8000/stats
```

## 📁 프로젝트 구조

```
DingQ/
├── DingQ_BE/                 # 백엔드 애플리케이션
│   ├── app/
│   │   ├── main.py          # FastAPI 메인 애플리케이션
│   │   ├── database.py      # PostgreSQL 연동 및 ORM
│   │   └── model/
│   │       ├── inference.py      # 이미지 인퍼런스 모델
│   │       ├── clip_search.py    # CLIP 검색 엔진
│   │       ├── vectorweight.npz  # 사전 훈련된 벡터 가중치
│   │       └── requirements.txt  # ML 모델 의존성
│   ├── database/
│   │   └── schema.sql       # PostgreSQL 스키마
│   ├── Dockerfile           # 백엔드 도커 설정
│   ├── requirements.txt     # Python 의존성
│   └── test_search_api.py   # API 테스트 스크립트
├── testImages/              # 테스트 이미지
├── docker-compose.yml       # 도커 컴포즈 설정
└── README.md               # 프로젝트 문서
```

## 🔍 사용 예시

### 1. 이미지 검색

```python
import requests

# 이미지 업로드 및 검색
with open('sketch.png', 'rb') as f:
    files = {'image': f}
    response = requests.post('http://localhost:8000/search', files=files)
    result = response.json()

# 결과 확인
for item in result['top5']:
    print(f"{item['label']}: {item['score']:.4f}")
```

### 2. 검색 결과 예시

```json
{
  "top5": [
    {
      "label": "home",
      "score": 0.8934,
      "url": "https://storage.googleapis.com/dingq-svg-icons/home.svg"
    },
    {
      "label": "house",
      "score": 0.8721,
      "url": "https://storage.googleapis.com/dingq-svg-icons/house.svg"
    }
  ],
  "processing_time": 0.234,
  "total_results": 251
}
```

## 🛡️ 보안 고려사항

- 비루트 사용자로 컨테이너 실행
- 환경 변수를 통한 데이터베이스 인증 정보 관리
- CORS 설정으로 허용된 오리진만 접근 가능

## 🚀 배포

### 프로덕션 환경

```bash
# 프로덕션 모드로 실행
docker-compose -f docker-compose.yml up -d

# 환경 변수 수정
# - DATABASE_URL: 프로덕션 PostgreSQL 연결 정보
# - CORS origins: 실제 프론트엔드 도메인으로 제한
```

### 모니터링

- 헬스체크: `GET /health`
- 통계: `GET /stats`
- 로그 확인: `docker-compose logs -f backend`

## 📊 성능 최적화

1. **CLIP 모델 캐싱**: 서버 시작 시 모델을 메모리에 로드하여 빠른 추론
2. **PostgreSQL 인덱싱**: 벡터 유사도 검색을 위한 IVFFlat 인덱스
3. **비동기 처리**: FastAPI의 비동기 기능으로 동시 요청 처리
4. **이미지 전처리**: 최적화된 이미지 전처리 파이프라인

## 🤝 기여하기

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 라이센스

이 프로젝트는 MIT 라이센스 하에 배포됩니다.

## 🆘 문제 해결

### 일반적인 문제들

1. **CLIP 모델 로딩 실패**
   - `vectorweight.npz` 파일 확인
   - 메모리 부족 시 도커 리소스 증가

2. **PostgreSQL 연결 실패**
   - 데이터베이스 서비스 상태 확인
   - 환경 변수 설정 확인

3. **이미지 업로드 실패**
   - 파일 크기 제한 확인
   - 지원되는 이미지 형식 확인

### 디버깅

```bash
# 컨테이너 로그 확인
docker-compose logs backend
docker-compose logs postgres

# 컨테이너 내부 접속
docker-compose exec backend bash
docker-compose exec postgres psql -U dingq_user -d dingq_db
```

---

**DingQ Team** - AI 기반 이미지 검색으로 더 나은 사용자 경험을 제공합니다.