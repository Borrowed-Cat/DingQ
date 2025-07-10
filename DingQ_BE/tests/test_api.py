import pytest
from fastapi.testclient import TestClient
from PIL import Image
import io
import base64
from app.main import app

client = TestClient(app)

def create_test_image():
    """테스트용 이미지 생성"""
    img = Image.new('RGB', (100, 100), color='red')
    img_byte_arr = io.BytesIO()
    img.save(img_byte_arr, format='PNG')
    img_byte_arr.seek(0)
    return img_byte_arr

class TestBasicEndpoints:
    def test_read_root(self):
        response = client.get("/")
        assert response.status_code == 200
        assert response.json() == {"message": "DingQ Backend API is running"}
    
    def test_health_check(self):
        response = client.get("/health")
        assert response.status_code == 200
        assert response.json() == {"status": "healthy", "service": "DingQ Backend"}

class TestSearchEndpoints:
    def test_normal_search_success(self):
        """일반 검색 성공 테스트"""
        test_image = create_test_image()
        
        response = client.post(
            "/api/search/normal",
            files={"image": ("test.png", test_image.getvalue(), "image/png")},
            params={"top_n": 3}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "success"
        assert data["mode"] == "normal"
        assert data["top_n"] == 3
        assert "results" in data
        assert "processing_time" in data
    
    def test_deep_search_success(self):
        """딥 검색 성공 테스트"""
        test_image = create_test_image()
        
        response = client.post(
            "/api/search/deep",
            files={"image": ("test.png", test_image.getvalue(), "image/png")},
            params={"top_n": 5}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "success"
        assert data["mode"] == "deep"
        assert data["top_n"] == 5
        assert "results" in data
        assert "refined_image" in data
        assert "processing_time" in data
    
    def test_search_invalid_file_type(self):
        """잘못된 파일 타입 테스트"""
        # 텍스트 파일로 테스트
        response = client.post(
            "/api/search/normal",
            files={"image": ("test.txt", b"not an image", "text/plain")}
        )
        
        assert response.status_code == 400
        assert "이미지 파일만 업로드 가능합니다" in response.json()["detail"]
    
    def test_search_no_file(self):
        """파일 없이 요청 테스트"""
        response = client.post("/api/search/normal")
        assert response.status_code == 422  # Validation error

class TestUploadEndpoints:
    def test_upload_sketch_success(self):
        """스케치 업로드 성공 테스트"""
        test_image = create_test_image()
        
        response = client.post(
            "/api/upload/sketch",
            files={"image": ("sketch.png", test_image.getvalue(), "image/png")}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "success"
        assert data["filename"] == "sketch.png"
        assert "size" in data
    
    def test_upload_invalid_file(self):
        """잘못된 파일 업로드 테스트"""
        response = client.post(
            "/api/upload/sketch",
            files={"image": ("test.txt", b"not an image", "text/plain")}
        )
        
        assert response.status_code == 400
        assert "이미지 파일만 업로드 가능합니다" in response.json()["detail"]

class TestErrorHandling:
    def test_large_image_handling(self):
        """큰 이미지 처리 테스트"""
        # 큰 이미지 생성 (10MB 이상)
        large_img = Image.new('RGB', (2000, 2000), color='blue')
        img_byte_arr = io.BytesIO()
        large_img.save(img_byte_arr, format='PNG', quality=95)
        img_byte_arr.seek(0)
        
        response = client.post(
            "/api/search/normal",
            files={"image": ("large.png", img_byte_arr.getvalue(), "image/png")}
        )
        
        # 서버가 큰 이미지를 처리할 수 있어야 함
        assert response.status_code in [200, 413]  # 413은 너무 큰 파일
    
    def test_missing_content_type(self):
        """Content-Type이 없는 경우 테스트"""
        test_image = create_test_image()
        
        response = client.post(
            "/api/search/normal",
            files={"image": ("test.png", test_image.getvalue())}  # content_type 없음
        )
        
        # content_type이 None인 경우 처리
        assert response.status_code in [200, 400]

if __name__ == "__main__":
    pytest.main([__file__, "-v"]) 