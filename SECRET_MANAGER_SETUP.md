# 🔐 Google Cloud Secret Manager 설정 가이드

## 개요
DingQ API를 **안전하게 GCP에 배포**하기 위해 Secret Manager를 사용하여 민감한 정보(API 키, 데이터베이스 비밀번호 등)를 보호합니다.

## 🔑 왜 Secret Manager를 사용해야 하나요?

### ❌ **기존 방식의 문제점**
```dockerfile
# ⚠️ 위험: Dockerfile에 하드코딩
ENV GOOGLE_API_KEY="AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
ENV DATABASE_PASSWORD="my-secret-password"
```

**문제:**
- 🚨 API 키가 Docker 이미지에 포함됨
- 🚨 소스 코드나 이미지를 공유하면 비밀 노출
- 🚨 버전 관리 시스템에 민감한 정보 저장
- 🚨 키 변경 시 전체 이미지 재빌드 필요

### ✅ **Secret Manager 사용의 장점**
- 🔒 민감한 정보가 이미지와 분리됨
- 🔄 런타임에 동적으로 시크릿 로드
- 🎯 세밀한 접근 권한 제어
- 📝 감사 로그 및 버전 관리
- 🔄 키 롤링 자동화 가능

## 🚀 1단계: Secret Manager API 활성화

```bash
# Secret Manager API 활성화
gcloud services enable secretmanager.googleapis.com

# 현재 프로젝트 확인
gcloud config get-value project
```

## 🔑 2단계: 시크릿 생성

### **방법 1: gcloud CLI 사용**
```bash
# Gemini AI API 키 시크릿 생성
echo -n "YOUR_ACTUAL_GEMINI_API_KEY" | gcloud secrets create gemini-api-key --data-file=-

# 데이터베이스 비밀번호 (옵션)
echo -n "your-db-password" | gcloud secrets create db-password --data-file=-

# 시크릿 목록 확인
gcloud secrets list
```

### **방법 2: Google Cloud Console 사용**
1. **Console** → **Security** → **Secret Manager**
2. **"시크릿 만들기"** 클릭
3. **시크릿 이름**: `gemini-api-key`
4. **시크릿 값**: 실제 Gemini AI API 키 입력
5. **"시크릿 만들기"** 클릭

## 🛡️ 3단계: 서비스 계정 설정

### **Cloud Run용 서비스 계정 생성**
```bash
PROJECT_ID="your-project-id"
SERVICE_ACCOUNT="dingq-api@$PROJECT_ID.iam.gserviceaccount.com"

# 서비스 계정 생성
gcloud iam service-accounts create dingq-api \
    --display-name="DingQ API Service Account" \
    --description="Service account for DingQ API on Cloud Run"
```

### **필요한 권한 부여**
```bash
# Secret Manager 접근 권한
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/secretmanager.secretAccessor"

# Cloud Storage 권한 (이미지 업로드용)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/storage.objectAdmin"

# Cloud Storage 버킷 권한
gsutil iam ch serviceAccount:$SERVICE_ACCOUNT:objectAdmin gs://your-bucket-name
```

## 🔧 4단계: 애플리케이션 코드 수정

### **main.py에서 Secret Manager 사용**
```python
from google.cloud import secretmanager

def get_secret(secret_name: str, project_id: str) -> str:
    """Secret Manager에서 시크릿 값 조회"""
    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/{project_id}/secrets/{secret_name}/versions/latest"
    response = client.access_secret_version(request={"name": name})
    return response.payload.data.decode("UTF-8")

# 프로덕션 환경에서 시크릿 로드
if os.getenv("ENVIRONMENT") == "production":
    GOOGLE_API_KEY = get_secret("gemini-api-key", PROJECT_ID)
else:
    GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")  # 개발 환경
```

## 🐳 5단계: 프로덕션 Dockerfile

### **보안 강화된 Dockerfile**
```dockerfile
# 민감한 정보 없는 프로덕션 Dockerfile
FROM python:3.11-slim

# 시스템 종속성 설치
RUN apt-get update && apt-get install -y gcc g++ cmake

# 앱 사용자 생성 (보안)
RUN useradd --create-home --shell /bin/bash app
WORKDIR /app

# 종속성 설치
COPY requirements.txt .
RUN pip install -r requirements.txt

# 애플리케이션 코드 복사
COPY app/ .
RUN chown -R app:app /app

# 비특권 사용자로 실행
USER app

# ✅ 민감한 정보 없음! 런타임에 Secret Manager에서 로드
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## 🚀 6단계: Cloud Run 배포

### **보안 배포 명령어**
```bash
gcloud run deploy dingq-api \
  --image gcr.io/$PROJECT_ID/dingq-api \
  --platform managed \
  --region asia-northeast3 \
  --allow-unauthenticated \
  --memory 2Gi \
  --set-env-vars="ENVIRONMENT=production,GOOGLE_CLOUD_PROJECT=$PROJECT_ID" \
  --service-account="dingq-api@$PROJECT_ID.iam.gserviceaccount.com"
```

## 🔍 7단계: 검증 및 테스트

### **시크릿 접근 테스트**
```bash
# Secret Manager 시크릿 읽기 테스트
gcloud secrets versions access latest --secret="gemini-api-key"

# Cloud Run 로그 확인
gcloud logs read --limit 50 --service=dingq-api
```

### **API 테스트**
```bash
# 서비스 URL 확인
SERVICE_URL=$(gcloud run services describe dingq-api --region asia-northeast3 --format 'value(status.url)')

# 상태 확인
curl $SERVICE_URL/

# 이미지 생성 테스트
curl -X POST $SERVICE_URL/generate \
  -F "description=cute cat icon" \
  -F "image=@test.jpg" \
  -F "num_images=2"
```

## 🛡️ 보안 모범 사례

### **✅ 해야 할 것들**
- 🔒 **최소 권한 원칙**: 필요한 최소한의 권한만 부여
- 🔄 **정기적인 키 롤링**: 주기적으로 API 키 변경
- 📝 **감사 로깅**: Secret Manager 접근 로그 모니터링
- 🎯 **환경별 분리**: 개발/스테이징/프로덕션 시크릿 분리

### **❌ 하지 말아야 할 것들**
- 🚨 Dockerfile이나 코드에 시크릿 하드코딩
- 🚨 환경변수로 민감한 정보 전달
- 🚨 Git에 시크릿 파일 커밋
- 🚨 과도한 권한 부여

## 💰 비용 최적화

### **Secret Manager 비용**
- **시크릿 저장**: $0.06/시크릿/월
- **API 호출**: 10,000건당 $0.03
- **무료 할당량**: 월 6개 시크릿, 28,000 API 호출

### **비용 절약 팁**
- 🎯 자주 변경되지 않는 시크릿만 저장
- ⚡ 애플리케이션 시작시 한 번만 로드 후 메모리 캐시
- 📊 불필요한 시크릿은 정기적으로 정리

## 🔧 문제 해결

### **일반적인 오류와 해결책**

#### **1. Permission Denied 오류**
```
ERROR: Permission denied to access secret
```
**해결책:**
```bash
# 서비스 계정에 Secret Accessor 역할 부여
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="serviceAccount:SERVICE_ACCOUNT" \
    --role="roles/secretmanager.secretAccessor"
```

#### **2. Secret Not Found 오류**
```
ERROR: Secret [gemini-api-key] not found
```
**해결책:**
```bash
# 시크릿 목록 확인
gcloud secrets list

# 시크릿 생성
echo -n "YOUR_API_KEY" | gcloud secrets create gemini-api-key --data-file=-
```

#### **3. 잘못된 프로젝트 ID**
```
ERROR: Invalid project ID
```
**해결책:**
```bash
# 현재 프로젝트 확인
gcloud config get-value project

# 올바른 프로젝트로 변경
gcloud config set project YOUR_PROJECT_ID
```

## 📚 추가 자료

- 📖 [Google Cloud Secret Manager 문서](https://cloud.google.com/secret-manager/docs)
- 🎥 [Secret Manager 모범 사례](https://cloud.google.com/secret-manager/docs/best-practices)
- 🔧 [Cloud Run에서 Secret Manager 사용](https://cloud.google.com/run/docs/configuring/secrets)

---

✅ **다음 단계**: `./deploy-to-cloudrun.sh YOUR_PROJECT_ID`로 안전한 배포를 진행하세요! 