import json
import os

import cv2
import numpy as np
import torch
from PIL import Image
from sklearn.metrics.pairwise import cosine_similarity
from transformers import CLIPImageProcessor, CLIPModel


class CLIPImageSearcher:
    """
    CLIP 모델을 사용한 이미지 유사도 검색 클래스
    """

    def __init__(
        self,
        reference_data_path="reference_combined_augmented_posted_data.npz",
        model_name="openai/clip-vit-base-patch32",
    ):
        """
        초기화 - 모델과 레퍼런스 데이터를 한번만 로드

        Args:
            reference_data_path (str): 레퍼런스 데이터 파일 경로
            model_name (str): 사용할 CLIP 모델명
        """
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.model_name = model_name
        self.reference_data_path = reference_data_path

        # CLIP 모델 로드
        print("CLIP 모델을 로드하는 중...")
        # (torch < 2.6) 보안 이슈 회피: safetensors 형식 사용
        self.model = CLIPModel.from_pretrained(model_name, use_safetensors=True)
        self.processor = CLIPImageProcessor.from_pretrained(model_name)
        print("모델 로드 완료")

        # 레퍼런스 데이터 로드
        self._load_reference_data()

    def _load_reference_data(self):
        """레퍼런스 데이터 로드"""
        if not os.path.exists(self.reference_data_path):
            raise FileNotFoundError(
                f"레퍼런스 데이터 파일을 찾을 수 없습니다: {self.reference_data_path}"
            )

        print("레퍼런스 데이터를 로드하는 중...")
        data = np.load(self.reference_data_path, allow_pickle=True)
        self.reference_vectors = data["vectors"]
        self.reference_labels = data["labels"]
        print(f"레퍼런스 벡터 개수: {len(self.reference_labels)}개")

    def preprocess_icon_image(self, pil_image, size=(224, 224), pad_color=255):
        """
        아이콘 이미지 전처리 함수

        Args:
            pil_image (PIL.Image): 입력 이미지
            size (tuple): 출력 크기 (height, width)
            pad_color (int): 패딩 색상

        Returns:url
            PIL.Image: 전처리된 이미지
        """
        img = np.array(pil_image.convert("L"))  # 흑백 변환
        _, binary = cv2.threshold(img, 128, 255, cv2.THRESH_BINARY_INV)  # 이진화
        kernel = np.ones((3, 3), np.uint8)
        clean = cv2.morphologyEx(binary, cv2.MORPH_OPEN, kernel)  # 노이즈 제거

        h, w = clean.shape
        scale = min(size[0] / h, size[1] / w)  # 비율 유지하며 리사이즈
        nh, nw = int(h * scale), int(w * scale)
        resized = cv2.resize(clean, (nw, nh))

        # 중앙정렬 패딩
        top = (size[0] - nh) // 2
        bottom = size[0] - nh - top
        left = (size[1] - nw) // 2
        right = size[1] - nw - left
        padded = cv2.copyMakeBorder(
            resized, top, bottom, left, right, cv2.BORDER_CONSTANT, value=(pad_color,)
        )

        pil_processed = Image.fromarray(padded).convert("RGB")
        return pil_processed

    def extract_image_features(self, image_path):
        """
        이미지에서 특징 벡터 추출

        Args:
            image_path (str): 이미지 파일 경로

        Returns:
            np.ndarray: 정규화된 특징 벡터
        """
        if not os.path.exists(image_path):
            raise FileNotFoundError(f"이미지 파일을 찾을 수 없습니다: {image_path}")

        image = Image.open(image_path)
        processed_image = self.preprocess_icon_image(image)
        inputs = self.processor(images=processed_image, return_tensors="pt")
        # Debug
        print("processor tensor shape:", inputs["pixel_values"].shape)
        inputs = {k: v.to(self.device) for k, v in inputs.items()}

        with torch.no_grad():
            features = self.model.get_image_features(**inputs)

        features = features.cpu().numpy()
        features = features / np.linalg.norm(features)  # L2 정규화
        return features[0]

    def search_similarity(self, image_path, top_k=20):
        """
        이미지 유사도 검색 함수

        Args:
            image_path (str): 검색할 이미지 파일 경로
            top_k (int): 상위 k개 결과 반환

        Returns:
            str: JSON 형태의 검색 결과
        """
        try:
            # 쿼리 이미지 임베딩 추출
            query_vector = self.extract_image_features(image_path).reshape(1, -1)

            # 유사도 계산
            similarities = cosine_similarity(query_vector, self.reference_vectors)[0]

            # 상위 결과 추출 (중복 제거)
            top_indices = similarities.argsort()[::-1]

            unique_results = []
            seen_base_names = set()

            for idx in top_indices:
                label = self.reference_labels[idx]
                # '_aug' 이전까지를 원본명으로 사용
                if "_aug" in label:
                    base_name = label.split("_aug")[0]
                else:
                    base_name = label

                if base_name not in seen_base_names:
                    seen_base_names.add(base_name)
                    unique_results.append(
                        {
                            "reference_name": base_name,
                            "similarity_score": float(similarities[idx]),
                        }
                    )

                if len(unique_results) >= top_k:
                    break

            # 결과를 JSON 형태로 반환
            result = {
                "query_image": image_path,
                "total_results": len(unique_results),
                "results": unique_results,
            }

            return json.dumps(result, ensure_ascii=False, indent=2)

        except Exception as e:
            error_result = {"error": str(e), "query_image": image_path}
            return json.dumps(error_result, ensure_ascii=False, indent=2)


if __name__ == "__main__":
    query_image_path = r"C:\Users\mh\Desktop\swbootcamp\test13.png"
    reference_data_path = r"C:\Users\mh\Desktop\swbootcamp\project\reference_combined_augmented_posted_data.npz"

    # 검색기 초기화 (모델과 데이터를 한번만 로드)
    searcher = CLIPImageSearcher(reference_data_path)

    # 여러 이미지 검색 (모델 재로드 없이)
    result_json = searcher.search_similarity(query_image_path)
    print(result_json)
