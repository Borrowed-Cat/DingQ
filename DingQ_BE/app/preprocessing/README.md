
# 전처리 개요


**아이콘 이미지에 대한 자동 캡션 생성 및 멀티모달 임베딩 벡터 생성**을 목표로 함.
Google Gemini API와 CLIP 모델을 활용하여, 이미지와 텍스트의 의미를 통합한 벡터를 생성하고 시각화해서 확인함.


## 📌 1. 아이콘 이미지 캡션 생성 – `generate_caption.ipynb`

- **Google Gemini API**를 활용해 아이콘 이미지를 분석하고,  
  해당 이미지에 대한 **한국어 캡션**을 생성합니다.
- 이후 CLIP 임베딩에 적합한 형식으로 **전처리**를 수행합니다.


## 📌 2. 멀티모달 임베딩 벡터 생성 – `embedding_pipeline.ipynb`

1. **딩뱃 이미지 전처리 및 증강**
   : sandstone에서 sandstone_aug
2. 이미지 + 캡션 데이터를 결합하여  
   **CLIP 모델 기반 멀티모달 임베딩 벡터 생성**
3. 생성된 벡터들을 **시각화**하여 확인


## 🔧 사용 모델 및 도구

- `Google Gemini API`: 이미지 캡션 생성
- `CLIP (openai/clip-vit-base-patch32)`: 이미지/텍스트 임베딩
- `scikit-learn`, `matplotlib`: 벡터 정규화 및 시각화
