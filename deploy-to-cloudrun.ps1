# GCP Cloud Run 배포 스크립트 (PowerShell 버전)
# 사용법: .\deploy-to-cloudrun.ps1 -ProjectId "your-project" -Region "asia-northeast3"

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectId = "your-project-id",
    
    [Parameter(Mandatory=$false)]
    [string]$Region = "asia-northeast3",
    
    [Parameter(Mandatory=$false)]
    [string]$ServiceName = "dingq-api"
)

# 에러 발생시 스크립트 중단
$ErrorActionPreference = "Stop"

# 변수 설정
$ImageName = "gcr.io/$ProjectId/$ServiceName"
$GcsBucket = "$ProjectId-dingq-icons"

Write-Host "🚀 DingQ API를 Cloud Run에 배포합니다..." -ForegroundColor Green
Write-Host "📋 프로젝트: $ProjectId" -ForegroundColor Cyan
Write-Host "🌏 리전: $Region" -ForegroundColor Cyan
Write-Host "🐳 이미지: $ImageName" -ForegroundColor Cyan
Write-Host "🪣 GCS 버킷: $GcsBucket" -ForegroundColor Cyan

try {
    # 1️⃣ GCP 프로젝트 설정
    Write-Host "`n1️⃣ GCP 프로젝트 설정 중..." -ForegroundColor Yellow
    gcloud config set project $ProjectId

    # 2️⃣ API 활성화
    Write-Host "`n2️⃣ 필요한 GCP API 활성화 중..." -ForegroundColor Yellow
    gcloud services enable cloudbuild.googleapis.com run.googleapis.com secretmanager.googleapis.com storage.googleapis.com

    # 3️⃣ Secret Manager에 시크릿 생성
    Write-Host "`n3️⃣ Secret Manager 시크릿 확인 중..." -ForegroundColor Yellow
    
    # Gemini API 키 시크릿 확인/생성
    $secretExists = $false
    try {
        gcloud secrets describe gemini-api-key --project=$ProjectId 2>$null
        $secretExists = $true
        Write-Host "✅ gemini-api-key 시크릿이 이미 존재합니다" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️ 'gemini-api-key' 시크릿이 없습니다." -ForegroundColor Yellow
        $geminiKey = Read-Host "🔑 Gemini AI API 키를 입력하세요"
        
        # PowerShell에서 안전하게 시크릿 생성
        $geminiKey | gcloud secrets create gemini-api-key --data-file=-
        Write-Host "✅ gemini-api-key 시크릿 생성 완료" -ForegroundColor Green
    }

    # 4️⃣ GCS 버킷 생성
    Write-Host "`n4️⃣ Google Cloud Storage 버킷 확인 중..." -ForegroundColor Yellow
    
    $bucketExists = $false
    try {
        gsutil ls -b "gs://$GcsBucket" 2>$null
        $bucketExists = $true
        Write-Host "✅ GCS 버킷이 이미 존재합니다: $GcsBucket" -ForegroundColor Green
    }
    catch {
        Write-Host "🪣 GCS 버킷 생성 중: $GcsBucket" -ForegroundColor Yellow
        gsutil mb -p $ProjectId -c STANDARD -l $Region "gs://$GcsBucket"
        
        # 공개 읽기 권한 설정
        gsutil iam ch allUsers:objectViewer "gs://$GcsBucket"
        Write-Host "✅ GCS 버킷 생성 및 권한 설정 완료" -ForegroundColor Green
    }

    # 5️⃣ Docker 이미지 빌드 및 푸시
    Write-Host "`n5️⃣ Docker 이미지 빌드 및 Google Container Registry 푸시 중..." -ForegroundColor Yellow
    Set-Location "DingQ_BE"

    # 프로덕션용 Dockerfile 사용
    docker build -f "..\Dockerfile.production" -t $ImageName .
    docker push $ImageName
    
    Write-Host "✅ Docker 이미지 푸시 완료: $ImageName" -ForegroundColor Green

    # 6️⃣ 서비스 계정 생성 및 권한 설정
    Write-Host "`n6️⃣ 서비스 계정 설정 중..." -ForegroundColor Yellow
    $ServiceAccount = "$ServiceName@$ProjectId.iam.gserviceaccount.com"
    
    # 서비스 계정 존재 확인
    try {
        gcloud iam service-accounts describe $ServiceAccount 2>$null
        Write-Host "✅ 서비스 계정이 이미 존재합니다: $ServiceAccount" -ForegroundColor Green
    }
    catch {
        # 서비스 계정 생성
        gcloud iam service-accounts create $ServiceName --display-name="DingQ API Service Account" --description="Service account for DingQ API on Cloud Run"
        Write-Host "✅ 서비스 계정 생성 완료: $ServiceAccount" -ForegroundColor Green
    }
    
    # 필요한 권한 부여
    gcloud projects add-iam-policy-binding $ProjectId --member="serviceAccount:$ServiceAccount" --role="roles/secretmanager.secretAccessor"
    gcloud projects add-iam-policy-binding $ProjectId --member="serviceAccount:$ServiceAccount" --role="roles/storage.objectAdmin"

    # 7️⃣ Cloud Run 서비스 배포
    Write-Host "`n7️⃣ Cloud Run 서비스 배포 중..." -ForegroundColor Yellow

    gcloud run deploy $ServiceName --image $ImageName --platform managed --region $Region --allow-unauthenticated --memory 2Gi --cpu 2 --timeout 300 --concurrency 80 --max-instances 10 --set-env-vars="ENVIRONMENT=production,GCS_BUCKET_NAME=$GcsBucket,GOOGLE_CLOUD_PROJECT=$ProjectId" --service-account=$ServiceAccount

    # 8️⃣ 배포 완료 정보
    Write-Host "`n8️⃣ 배포 완료! 서비스 정보:" -ForegroundColor Yellow
    $ServiceUrl = gcloud run services describe $ServiceName --platform managed --region $Region --format 'value(status.url)'

    Write-Host "`n🎉 배포 성공!" -ForegroundColor Green
    Write-Host "🌐 서비스 URL: $ServiceUrl" -ForegroundColor Cyan
    Write-Host "📱 API 테스트: $ServiceUrl/" -ForegroundColor Cyan
    Write-Host "🔍 검색 API: $ServiceUrl/search" -ForegroundColor Cyan
    Write-Host "🎨 생성 API: $ServiceUrl/generate" -ForegroundColor Cyan
    Write-Host "🖼️ 이미지 목록: $ServiceUrl/images" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📋 다음 단계:" -ForegroundColor Yellow
    Write-Host "1. Secret Manager에서 시크릿 값들을 확인하세요" -ForegroundColor White
    Write-Host "2. GCS 버킷 권한을 검토하세요" -ForegroundColor White
    Write-Host "3. API 테스트를 진행하세요" -ForegroundColor White
    Write-Host ""
    Write-Host "🔧 유용한 명령어:" -ForegroundColor Yellow
    Write-Host "  gcloud run services list --region $Region" -ForegroundColor White
    Write-Host "  gcloud logs read --service $ServiceName --region $Region" -ForegroundColor White
    Write-Host "  gcloud secrets list" -ForegroundColor White

    Set-Location ".."
}
catch {
    Write-Host "`n❌ 배포 중 오류 발생: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "🔧 문제 해결을 위해 다음을 확인하세요:" -ForegroundColor Yellow
    Write-Host "1. gcloud CLI가 설치되고 인증되었는지 확인" -ForegroundColor White
    Write-Host "2. Docker가 실행 중인지 확인" -ForegroundColor White
    Write-Host "3. 프로젝트 ID와 권한을 확인" -ForegroundColor White
    Set-Location ".."
    exit 1
}

Write-Host "`n✅ 스크립트 실행 완료!" -ForegroundColor Green 