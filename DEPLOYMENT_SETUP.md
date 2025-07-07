# 🚀 DingQ 배포 설정 가이드

## 📋 환경 정보
- **프로젝트 ID**: `ceremonial-hold-463014-r7`
- **리전**: `asia-northeast3` (한국 서울)

## 🔧 PowerShell 환경변수 설정

아래 명령어를 PowerShell에서 실행하여 환경변수를 설정하세요:

```powershell
# GCP 프로젝트 설정
$env:GCP_PROJECT_ID = "ceremonial-hold-463014-r7"
$env:GCP_REGION = "asia-northeast3"
$env:PROJECT_ID = "ceremonial-hold-463014-r7"
$env:REGION = "asia-northeast3"
$env:SERVICE_NAME = "dingq-backend"

# 설정 확인
Write-Host "GCP_PROJECT_ID: $env:GCP_PROJECT_ID"
Write-Host "GCP_REGION: $env:GCP_REGION"
Write-Host "SERVICE_NAME: $env:SERVICE_NAME"
```

## 🏗️ 배포 명령어

### 1. 로컬 환경 실행
```powershell
# 로컬 서비스 시작
.\start-local.ps1

# 로그 확인
.\start-local.ps1 -Logs

# 테스트 포함 시작
.\start-local.ps1 -Test
```

### 2. GCP 배포
```powershell
# 환경변수 설정 (위 명령어 실행)
$env:GCP_PROJECT_ID = "ceremonial-hold-463014-r7"
$env:GCP_REGION = "asia-northeast3"

# 배포 실행
cd DingQ_BE
.\deploy.ps1
```

### 3. 기존 bash 스크립트 사용 (WSL/Git Bash)
```bash
# 환경변수 설정
export GCP_PROJECT_ID="ceremonial-hold-463014-r7"
export GCP_REGION="asia-northeast3"

# 배포 실행
cd DingQ_BE
./deploy.sh
```

## 🔍 확인 사항

### 로컬 환경
- **백엔드 API**: http://localhost:8000
- **API 문서**: http://localhost:8000/docs
- **헬스 체크**: http://localhost:8000/health

### GCP 배포 후
- **서비스 URL**: https://dingq-backend-[random-id]-du.a.run.app
- **헬스 체크**: [서비스 URL]/health
- **API 문서**: [서비스 URL]/docs

## 🛠️ 트러블슈팅

### PowerShell 실행 정책 문제
```powershell
# 실행 정책 확인
Get-ExecutionPolicy

# 실행 정책 변경 (필요시)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### gcloud CLI 설치
Windows에서 gcloud CLI를 설치하려면:
1. https://cloud.google.com/sdk/docs/install-sdk 접속
2. Windows용 설치 파일 다운로드
3. 설치 후 PowerShell 재시작

### 인증 설정
```powershell
# gcloud 로그인
gcloud auth login

# 프로젝트 설정
gcloud config set project ceremonial-hold-463014-r7

# Docker 인증
gcloud auth configure-docker
```

## 🔄 자동 배포 (GitHub Actions)

GitHub Repository에 다음 Secrets를 추가하세요:
- `GCP_PROJECT_ID`: `ceremonial-hold-463014-r7`
- `GCP_SA_KEY`: 서비스 계정 JSON 키

설정 후 main 또는 gcp-test 브랜치에 push하면 자동으로 배포됩니다.

## 📞 문의

배포 중 문제가 발생하면 다음을 확인하세요:
1. 환경변수 설정 여부
2. gcloud CLI 인증 상태
3. Docker 설치 및 실행 상태
4. 네트워크 연결 상태 