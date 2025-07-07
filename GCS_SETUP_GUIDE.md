# Google Cloud Storage 설정 가이드

DingQ 프로젝트에서 생성된 아이콘 이미지를 Google Cloud Storage에 저장하기 위한 설정 가이드입니다.

## 📋 사전 준비사항

1. **Google Cloud Platform 계정** - [GCP 콘솔](https://console.cloud.google.com/) 접근 가능
2. **Google Cloud SDK** 설치 (선택사항)
3. **결제 계정** 활성화 (무료 크레딧 사용 가능)

## 🚀 단계별 설정

### 1단계: Google Cloud 프로젝트 생성

1. [GCP 콘솔](https://console.cloud.google.com/)에 로그인
2. 상단의 프로젝트 선택 드롭다운 클릭
3. **"새 프로젝트"** 클릭
4. 프로젝트 이름 입력 (예: `dingq-storage`)
5. **"만들기"** 클릭

### 2단계: Cloud Storage API 활성화

1. GCP 콘솔에서 **"API 및 서비스"** > **"라이브러리"**로 이동
2. `Cloud Storage API` 검색
3. **"사용 설정"** 클릭

### 3단계: Storage 버킷 생성

1. GCP 콘솔에서 **"Cloud Storage"** > **"버킷"**으로 이동
2. **"버킷 만들기"** 클릭
3. 버킷 설정:
   - **이름**: `dingq-generated-icons` (전 세계에서 고유해야 함)
   - **위치**: `asia-northeast3` (서울) 권장
   - **저장소 클래스**: `Standard`
   - **액세스 제어**: `세밀한 제어`
4. **"만들기"** 클릭

### 4단계: 서비스 계정 생성

1. GCP 콘솔에서 **"IAM 및 관리자"** > **"서비스 계정"**으로 이동
2. **"서비스 계정 만들기"** 클릭
3. 서비스 계정 정보:
   - **이름**: `dingq-storage-service`
   - **설명**: `DingQ 이미지 저장용 서비스 계정`
4. **"만들기 및 계속하기"** 클릭
5. 역할 부여:
   - **"Storage Object Admin"** 역할 추가
   - **"Storage Legacy Bucket Writer"** 역할 추가 (선택사항)
6. **"완료"** 클릭

### 5단계: 서비스 계정 키 다운로드

1. 생성된 서비스 계정 클릭
2. **"키"** 탭으로 이동
3. **"키 추가"** > **"새 키 만들기"** 클릭
4. **JSON** 형식 선택
5. **"만들기"** 클릭 (자동으로 키 파일 다운로드)

### 6단계: 프로젝트에 키 파일 설정

1. 다운로드받은 JSON 키 파일을 프로젝트 루트에 복사
2. 파일명을 `gcs-service-account.json`으로 변경
3. `.gitignore`에 추가하여 버전 관리에서 제외:
   ```
   # Google Cloud Service Account Key
   gcs-service-account.json
   *.json
   ```

### 7단계: 환경변수 설정

#### 로컬 개발환경

`.env` 파일 생성 및 설정:
```bash
# Google Cloud Storage 설정
GOOGLE_APPLICATION_CREDENTIALS=./gcs-service-account.json
GCS_BUCKET_NAME=dingq-generated-icons
```

#### 배포 환경 (Docker/Cloud Run)

**Dockerfile에 추가:**
```dockerfile
# 서비스 계정 키 복사
COPY gcs-service-account.json /app/gcs-service-account.json

# 환경변수 설정
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/gcs-service-account.json
ENV GCS_BUCKET_NAME=dingq-generated-icons
```

**환경변수로 설정:**
```bash
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/gcs-service-account.json
export GCS_BUCKET_NAME=dingq-generated-icons
```

## 🔧 버킷 공개 설정 (선택사항)

생성된 이미지에 공개 URL로 접근하려면:

1. 버킷 선택 > **"권한"** 탭
2. **"주 구성원 추가"** 클릭
3. 새 주 구성원: `allUsers`
4. 역할: **"Storage 객체 뷰어"**
5. **"저장"** 클릭

⚠️ **보안 주의사항**: 이 설정으로 버킷의 모든 파일이 공개됩니다.

## 📊 요금 정보

### Storage 비용 (서울 리전)
- **Standard 저장소**: $0.023/GB/월
- **작업 비용**: 
  - 업로드: $0.005/1,000회
  - 다운로드: $0.001/1,000회
- **네트워크**: 아시아 내 송신 $0.09/GB

### 예상 비용 (월간)
- **이미지 1,000개** (각 500KB): 약 $0.01
- **이미지 10,000개** (각 500KB): 약 $0.12
- **업로드 10,000회**: 약 $0.05

## 🧪 테스트

### 1. API 테스트

```bash
# 서버 상태 확인 (GCS 연결 상태 포함)
curl http://localhost:8000/

# 이미지 생성 (GCS 자동 저장)
curl -X POST "http://localhost:8000/generate" \
  -F "description=집" \
  -F "image=@test_sketch.png" \
  -F "temperature=0.5" \
  -F "target_count=3"

# GCS 이미지 목록 조회
curl "http://localhost:8000/images?prefix=generated/&limit=10"
```

### 2. GCS 연결 테스트

```python
from google.cloud import storage

# 클라이언트 생성 테스트
client = storage.Client()
bucket = client.bucket('dingq-generated-icons')
print(f"버킷 존재: {bucket.exists()}")
```

## 🔍 트러블슈팅

### 1. 인증 오류
```
DefaultCredentialsError: Could not automatically determine credentials
```
**해결**: `GOOGLE_APPLICATION_CREDENTIALS` 환경변수 확인

### 2. 권한 오류
```
403 Forbidden: user does not have storage.objects.create access
```
**해결**: 서비스 계정에 `Storage Object Admin` 역할 부여

### 3. 버킷을 찾을 수 없음
```
404 Not Found: bucket does not exist
```
**해결**: `GCS_BUCKET_NAME` 환경변수와 실제 버킷명 일치 확인

### 4. 파일 업로드 실패
```
BadRequest: Upload request failed
```
**해결**: 이미지 파일 크기 및 형식 확인 (최대 32MB)

## 📚 추가 리소스

- [Google Cloud Storage 문서](https://cloud.google.com/storage/docs)
- [Python 클라이언트 라이브러리](https://googleapis.dev/python/storage/latest/)
- [GCS 가격 계산기](https://cloud.google.com/products/calculator)
- [IAM 권한 가이드](https://cloud.google.com/storage/docs/access-control/iam-permissions)

## 🔐 보안 모범 사례

1. **서비스 계정 키 보안**:
   - 키 파일을 버전 관리에 커밋하지 마세요
   - 정기적으로 키 순환 (3-6개월)
   
2. **최소 권한 원칙**:
   - 필요한 최소한의 권한만 부여
   - 프로덕션과 개발 환경 분리

3. **네트워크 보안**:
   - VPC 내에서만 접근 허용 (선택사항)
   - IP 제한 설정 고려

이제 DingQ에서 생성된 아이콘들이 자동으로 Google Cloud Storage에 저장되고, 프론트엔드에서 쉽게 접근할 수 있습니다! 🎉 