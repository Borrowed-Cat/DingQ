#!/usr/bin/env python3
"""
DingQ Backend API 테스트 스크립트
"""

import requests
import json
from PIL import Image
import io
import numpy as np

# 서버 URL
BASE_URL = "http://localhost:8002"

def create_test_image():
    """테스트용 이미지 생성"""
    # 간단한 스케치 이미지 생성 (흰 배경에 검은 선)
    img = Image.new('RGB', (224, 224), color='white')
    pixels = img.load()
    
    # 간단한 선 그리기
    for i in range(50, 174):
        pixels[i, 100] = (0, 0, 0)  # 가로선
        pixels[112, i] = (0, 0, 0)  # 세로선
    
    return img

def test_health_check():
    """헬스 체크 테스트"""
    print("=== 헬스 체크 테스트 ===")
    try:
        response = requests.get(f"{BASE_URL}/health")
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"오류: {e}")
        return False

def test_normal_search():
    """일반 검색 테스트"""
    print("\n=== 일반 검색 테스트 ===")
    try:
        # 테스트 이미지 생성
        test_image = create_test_image()
        
        # 이미지를 바이트로 변환
        img_byte_arr = io.BytesIO()
        test_image.save(img_byte_arr, format='PNG')
        img_byte_arr.seek(0)
        
        # API 호출
        files = {'image': ('test_sketch.png', img_byte_arr, 'image/png')}
        params = {'top_n': 3}
        
        response = requests.post(f"{BASE_URL}/api/search/normal", files=files, params=params)
        
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"Mode: {result.get('mode')}")
            print(f"Top N: {result.get('top_n')}")
            print(f"Results Count: {len(result.get('results', []))}")
            print("First Result:")
            if result.get('results'):
                print(json.dumps(result['results'][0], indent=2, ensure_ascii=False))
        else:
            print(f"Error: {response.text}")
        
        return response.status_code == 200
        
    except Exception as e:
        print(f"오류: {e}")
        return False

def test_deep_search():
    """Deep Search 테스트"""
    print("\n=== Deep Search 테스트 ===")
    try:
        # 테스트 이미지 생성
        test_image = create_test_image()
        
        # 이미지를 바이트로 변환
        img_byte_arr = io.BytesIO()
        test_image.save(img_byte_arr, format='PNG')
        img_byte_arr.seek(0)
        
        # API 호출
        files = {'image': ('test_sketch.png', img_byte_arr, 'image/png')}
        params = {'top_n': 3}
        
        response = requests.post(f"{BASE_URL}/api/search/deep", files=files, params=params)
        
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"Mode: {result.get('mode')}")
            print(f"Top N: {result.get('top_n')}")
            print(f"Results Count: {len(result.get('results', []))}")
            print("First Result:")
            if result.get('results'):
                print(json.dumps(result['results'][0], indent=2, ensure_ascii=False))
        else:
            print(f"Error: {response.text}")
        
        return response.status_code == 200
        
    except Exception as e:
        print(f"오류: {e}")
        return False

def test_upload_sketch():
    """스케치 업로드 테스트"""
    print("\n=== 스케치 업로드 테스트 ===")
    try:
        # 테스트 이미지 생성
        test_image = create_test_image()
        
        # 이미지를 바이트로 변환
        img_byte_arr = io.BytesIO()
        test_image.save(img_byte_arr, format='PNG')
        img_byte_arr.seek(0)
        
        # API 호출
        files = {'image': ('test_sketch.png', img_byte_arr, 'image/png')}
        
        response = requests.post(f"{BASE_URL}/api/upload/sketch", files=files)
        
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"Message: {result.get('message')}")
            print(f"Filename: {result.get('filename')}")
            print(f"Size: {result.get('size')}")
        else:
            print(f"Error: {response.text}")
        
        return response.status_code == 200
        
    except Exception as e:
        print(f"오류: {e}")
        return False

def main():
    """메인 테스트 함수"""
    print("DingQ Backend API 테스트 시작")
    print("=" * 50)
    
    # 서버가 실행 중인지 확인
    if not test_health_check():
        print("서버가 실행되지 않았습니다. 먼저 서버를 시작해주세요.")
        print("명령어: uvicorn app.main:app --reload --host 0.0.0.0 --port 8000")
        return
    
    # 각 API 테스트 실행
    tests = [
        test_upload_sketch,
        test_normal_search,
        test_deep_search
    ]
    
    results = []
    for test in tests:
        results.append(test())
    
    # 결과 요약
    print("\n" + "=" * 50)
    print("테스트 결과 요약:")
    print(f"성공: {sum(results)}/{len(results)}")
    
    if all(results):
        print("🎉 모든 테스트가 성공했습니다!")
    else:
        print("❌ 일부 테스트가 실패했습니다.")

if __name__ == "__main__":
    main() 