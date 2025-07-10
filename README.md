# DingQ - AI 기반 이미지 검색 시스템

스케치 이미지를 기반으로 유사한 SVG 아이콘을 찾아주는 AI 검색 서비스입니다.

## 🏗️ 시스템 구조

### 백엔드 (DingQ_BE)
- **FastAPI + PostgreSQL**: 고성능 비동기 API 서버
- **CLIP 모델**: OpenAI CLIP을 활용한 의미적 이미지 유사도 검색
- **벡터 검색**: pgvector 확장을 통한 고속 유사도 검색

### 프론트엔드 (DingQ_FE)
- **Flutter**: 크로스플랫폼 모바일/웹 애플리케이션 (예제 코드 포함)
- **API 연동**: 백엔드와 연동하는 Flutter 예제 구현체 제공

### 인프라
- **Docker Compose**: 로컬 개발환경 및 서비스 컨테이너화
- **Google Cloud Platform**: Cloud Run을 통한 서버리스 배포
