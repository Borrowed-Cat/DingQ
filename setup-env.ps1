# DingQ Google Cloud Storage 환경변수 설정 스크립트

Write-Host "🚀 DingQ GCS 환경변수 설정 중..." -ForegroundColor Green

# Google Cloud Storage 환경변수 설정
$env:GOOGLE_APPLICATION_CREDENTIALS = "./gcs-service-account.json"
$env:GCS_BUCKET_NAME = "dingq-generated-icons"
$env:VECTOR_WEIGHT_PATH = "model/vectorweight.npz"

Write-Host "✅ 환경변수 설정 완료!" -ForegroundColor Green
Write-Host ""
Write-Host "설정된 환경변수:" -ForegroundColor Yellow
Write-Host "  GOOGLE_APPLICATION_CREDENTIALS = $env:GOOGLE_APPLICATION_CREDENTIALS" -ForegroundColor Cyan
Write-Host "  GCS_BUCKET_NAME = $env:GCS_BUCKET_NAME" -ForegroundColor Cyan
Write-Host "  VECTOR_WEIGHT_PATH = $env:VECTOR_WEIGHT_PATH" -ForegroundColor Cyan
Write-Host ""
Write-Host "이제 'python DingQ_BE/app/main.py' 명령으로 서버를 실행할 수 있습니다!" -ForegroundColor Green 