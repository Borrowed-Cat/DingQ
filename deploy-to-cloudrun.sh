#!/bin/bash
# GCP Cloud Run 배포 스크립트 (보안 강화 버전)
# 사용법: ./deploy-to-cloudrun.sh [PROJECT_ID] [REGION]

set -e  # 에러 발생시 스크립트 중단

# 변수 설정
PROJECT_ID=${1:-"your-project-id"}  # 첫 번째 인자 또는 기본값
REGION=${2:-"asia-northeast3"}      # 두 번째 인자 또는 기본값 (서울)
SERVICE_NAME="dingq-api"
IMAGE_NAME="gcr.io/$PROJECT_ID/$SERVICE_NAME"
GCS_BUCKET="$PROJECT_ID-dingq-icons"

echo "🚀 DingQ API를 Cloud Run에 배포합니다..."
echo "📋 프로젝트: $PROJECT_ID"
echo "🌏 리전: $REGION"
echo "🐳 이미지: $IMAGE_NAME"
echo "🪣 GCS 버킷: $GCS_BUCKET"

# 1️⃣ GCP 프로젝트 설정
echo -e "\n1️⃣ GCP 프로젝트 설정 중..."
gcloud config set project $PROJECT_ID

# 2️⃣ API 활성화
echo -e "\n2️⃣ 필요한 GCP API 활성화 중..."
gcloud services enable \
  cloudbuild.googleapis.com \
  run.googleapis.com \
  secretmanager.googleapis.com \
  storage.googleapis.com

# 3️⃣ Secret Manager에 시크릿 생성 (이미 있으면 스킵)
echo -e "\n3️⃣ Secret Manager 시크릿 확인 중..."

# Gemini API 키 시크릿 확인/생성
if ! gcloud secrets describe gemini-api-key --project=$PROJECT_ID > /dev/null 2>&1; then
    echo "⚠️ 'gemini-api-key' 시크릿이 없습니다."
    read -p "🔑 Gemini AI API 키를 입력하세요: " GEMINI_KEY
    echo -n "$GEMINI_KEY" | gcloud secrets create gemini-api-key --data-file=-
    echo "✅ gemini-api-key 시크릿 생성 완료"
else
    echo "✅ gemini-api-key 시크릿이 이미 존재합니다"
fi

# 4️⃣ GCS 버킷 생성 (이미 있으면 스킵)
echo -e "\n4️⃣ Google Cloud Storage 버킷 확인 중..."
if ! gsutil ls -b gs://$GCS_BUCKET > /dev/null 2>&1; then
    echo "🪣 GCS 버킷 생성 중: $GCS_BUCKET"
    gsutil mb -p $PROJECT_ID -c STANDARD -l $REGION gs://$GCS_BUCKET
    
    # 공개 읽기 권한 설정 (이미지 URL 접근용)
    gsutil iam ch allUsers:objectViewer gs://$GCS_BUCKET
    echo "✅ GCS 버킷 생성 및 권한 설정 완료"
else
    echo "✅ GCS 버킷이 이미 존재합니다: $GCS_BUCKET"
fi

# 5️⃣ Docker 이미지 빌드 및 푸시
echo -e "\n5️⃣ Docker 이미지 빌드 및 Google Container Registry 푸시 중..."
cd DingQ_BE

# 프로덕션용 Dockerfile 사용
docker build -f ../Dockerfile.production -t $IMAGE_NAME .
docker push $IMAGE_NAME

echo "✅ Docker 이미지 푸시 완료: $IMAGE_NAME"

# 6️⃣ Cloud Run 서비스 배포
echo -e "\n6️⃣ Cloud Run 서비스 배포 중..."

# Cloud Run에 서비스 배포 (Secret Manager 사용)
gcloud run deploy $SERVICE_NAME \
  --image $IMAGE_NAME \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --memory 2Gi \
  --cpu 2 \
  --timeout 300 \
  --concurrency 80 \
  --max-instances 10 \
  --set-env-vars="ENVIRONMENT=production,GCS_BUCKET_NAME=$GCS_BUCKET,GOOGLE_CLOUD_PROJECT=$PROJECT_ID" \
  --service-account="$SERVICE_NAME@$PROJECT_ID.iam.gserviceaccount.com"

# 7️⃣ 서비스 URL 가져오기
echo -e "\n7️⃣ 배포 완료! 서비스 정보:"
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --platform managed --region $REGION --format 'value(status.url)')

echo "🎉 배포 성공!"
echo "🌐 서비스 URL: $SERVICE_URL"
echo "📱 API 테스트: $SERVICE_URL/"
echo "🔍 검색 API: $SERVICE_URL/search"
echo "🎨 생성 API: $SERVICE_URL/generate"
echo "🖼️ 이미지 목록: $SERVICE_URL/images"
echo ""
echo "📋 다음 단계:"
echo "1. Secret Manager에서 시크릿 값들을 확인하세요"
echo "2. GCS 버킷 권한을 검토하세요"
echo "3. API 테스트를 진행하세요"

cd .. 