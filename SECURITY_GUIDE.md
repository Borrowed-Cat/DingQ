# 🔐 DingQ 보안 설정 가이드

DingQ 서비스의 접근 제어를 설정하는 다양한 방법을 안내합니다.

## 📋 보안 방법 비교

| 방법 | 보안 수준 | 설정 난이도 | 사용 용도 |
|------|-----------|-------------|-----------|
| **IAM 인증** | ⭐⭐⭐⭐⭐ | 쉬움 | 내부 사용자 관리 |
| **API 키** | ⭐⭐⭐⭐ | 쉬움 | 외부 API 연동 |
| **공개 접근** | ⭐ | 가장 쉬움 | 테스트/데모용 |

---

## 🔑 방법 1: IAM 인증 (추천)

### **장점**
- Google Cloud IAM과 완전 통합
- 사용자별 세밀한 권한 관리
- 토큰 자동 만료로 보안성 높음

### **배포 방법**
```cmd
# 보안 배포 스크립트 실행
secure-deploy.bat

# 또는 수동 배포
gcloud run deploy dingq-backend ^
  --image gcr.io/ceremonial-hold-463014-r7/dingq-backend ^
  --platform managed ^
  --region asia-northeast3 ^
  --no-allow-unauthenticated ^
  --memory 4Gi ^
  --cpu 2 ^
  --port 8000
```

### **사용자 권한 부여**
```cmd
# 특정 사용자에게 접근 권한 부여
gcloud run services add-iam-policy-binding dingq-backend ^
  --region=asia-northeast3 ^
  --member="user:사용자이메일@gmail.com" ^
  --role="roles/run.invoker"

# 본인 계정에 권한 부여
gcloud run services add-iam-policy-binding dingq-backend ^
  --region=asia-northeast3 ^
  --member="user:%gcloud config get-value account%" ^
  --role="roles/run.invoker"
```

### **서비스 접근 방법**
```cmd
# 인증된 요청
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" ^
  https://your-service-url/health

# 이미지 검색
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" ^
  -F "image=@test.png" ^
  https://your-service-url/search
```

---

## 🔑 방법 2: API 키 인증

### **장점**
- 간단한 구현
- 외부 시스템과 연동 용이
- 키 별 사용량 추적 가능

### **배포 방법**
```cmd
# 보안 배포 스크립트에서 API 키 옵션 선택
secure-deploy.bat

# 또는 수동으로 API 키 설정
set API_KEY=your-secret-api-key-here
gcloud run deploy dingq-backend ^
  --image gcr.io/ceremonial-hold-463014-r7/dingq-backend ^
  --platform managed ^
  --region asia-northeast3 ^
  --allow-unauthenticated ^
  --memory 4Gi ^
  --cpu 2 ^
  --port 8000 ^
  --set-env-vars "API_KEY=%API_KEY%"
```

### **서비스 접근 방법**
```cmd
# API 키로 인증
curl -H "X-API-Key: your-secret-api-key-here" ^
  https://your-service-url/health

# 이미지 검색
curl -H "X-API-Key: your-secret-api-key-here" ^
  -F "image=@test.png" ^
  https://your-service-url/search
```

---

## 🔑 방법 3: 공개 접근 (테스트용)

### **주의사항**
- ⚠️ 보안 위험: 누구나 접근 가능
- 비용 증가 가능성
- 프로덕션 환경에서는 권장하지 않음

### **배포 방법**
```cmd
# 기존 방식대로 배포
deploy-cmd.bat

# 또는 수동 배포
gcloud run deploy dingq-backend ^
  --image gcr.io/ceremonial-hold-463014-r7/dingq-backend ^
  --platform managed ^
  --region asia-northeast3 ^
  --allow-unauthenticated ^
  --memory 4Gi ^
  --cpu 2 ^
  --port 8000
```

---

## 🛠️ 보안 관리 명령어

### **현재 권한 확인**
```cmd
gcloud run services get-iam-policy dingq-backend --region=asia-northeast3
```

### **사용자 권한 제거**
```cmd
gcloud run services remove-iam-policy-binding dingq-backend ^
  --region=asia-northeast3 ^
  --member="user:사용자이메일@gmail.com" ^
  --role="roles/run.invoker"
```

### **서비스를 다시 공개로 변경**
```cmd
gcloud run services add-iam-policy-binding dingq-backend ^
  --region=asia-northeast3 ^
  --member="allUsers" ^
  --role="roles/run.invoker"
```

### **인증 상태 확인**
```cmd
curl https://your-service-url/auth/status
```

---

## 📊 실제 사용 예시

### **1. 팀 내부 사용**
```cmd
# 팀원들에게 접근 권한 부여
gcloud run services add-iam-policy-binding dingq-backend ^
  --region=asia-northeast3 ^
  --member="user:teammate1@company.com" ^
  --role="roles/run.invoker"

gcloud run services add-iam-policy-binding dingq-backend ^
  --region=asia-northeast3 ^
  --member="user:teammate2@company.com" ^
  --role="roles/run.invoker"
```

### **2. 외부 API 연동**
```cmd
# API 키 생성 및 설정
set API_KEY=sk-dingq-prod-abc123def456
gcloud run deploy dingq-backend ^
  --set-env-vars "API_KEY=%API_KEY%"

# 외부 시스템에서 사용
curl -H "X-API-Key: sk-dingq-prod-abc123def456" ^
  -F "image=@user_sketch.png" ^
  https://your-service-url/search
```

### **3. 임시 테스트용**
```cmd
# 일시적으로 공개 접근 허용
gcloud run services add-iam-policy-binding dingq-backend ^
  --region=asia-northeast3 ^
  --member="allUsers" ^
  --role="roles/run.invoker"

# 테스트 후 권한 제거
gcloud run services remove-iam-policy-binding dingq-backend ^
  --region=asia-northeast3 ^
  --member="allUsers" ^
  --role="roles/run.invoker"
```

---

## 🚨 보안 모범 사례

### **✅ 권장 사항**
1. **프로덕션에서는 IAM 인증 사용**
2. **API 키는 주기적으로 갱신**
3. **사용하지 않는 권한은 즉시 제거**
4. **접근 로그 모니터링**

### **❌ 피해야 할 사항**
1. **API 키를 코드에 하드코딩**
2. **공개 접근을 프로덕션에서 사용**
3. **권한 부여 후 관리하지 않음**
4. **API 키를 공개 저장소에 커밋**

---

## 🔍 문제 해결

### **403 Forbidden 오류**
```cmd
# 권한 확인
gcloud run services get-iam-policy dingq-backend --region=asia-northeast3

# 본인 계정에 권한 부여
gcloud run services add-iam-policy-binding dingq-backend ^
  --region=asia-northeast3 ^
  --member="user:$(gcloud config get-value account)" ^
  --role="roles/run.invoker"
```

### **401 Unauthorized 오류**
```cmd
# 인증 토큰 갱신
gcloud auth login

# API 키 확인
curl https://your-service-url/auth/status
```

### **서비스 URL 찾기**
```cmd
gcloud run services describe dingq-backend ^
  --region=asia-northeast3 ^
  --format="value(status.url)"
```

---

## 📞 추가 도움

보안 설정에 문제가 있거나 추가 기능이 필요하면:

1. `secure-deploy.bat` 스크립트 실행
2. `SECURITY_GUIDE.md` 문서 참고
3. Google Cloud Console에서 Cloud Run 서비스 확인

**Happy Secure Coding! 🔐** 