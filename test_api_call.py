#!/usr/bin/env python3
"""
DingQ API 테스트 스크립트
"""

import requests
import json
import time
import os

# 서비스 URL (실제 URL로 변경하세요)
API_BASE_URL = "https://your-service-url"  # 실제 URL로 변경 필요

def check_health():
    """서비스 헬스 체크"""
    try:
        response = requests.get(f"{API_BASE_URL}/health")
        print(f"🩺 Health Check: {response.status_code}")
        print(f"📊 Response: {response.json()}")
        return response.json()
    except Exception as e:
        print(f"❌ Health check failed: {e}")
        return None

def test_image_search(image_path):
    """이미지 검색 테스트"""
    if not os.path.exists(image_path):
        print(f"❌ 이미지 파일을 찾을 수 없습니다: {image_path}")
        return None
    
    try:
        with open(image_path, 'rb') as f:
            files = {'image': f}
            response = requests.post(f"{API_BASE_URL}/search", files=files)
        
        print(f"🔍 Search API: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ 검색 성공!")
            print(f"📈 처리 시간: {result.get('processing_time', 0):.2f}초")
            print(f"🎯 결과 개수: {len(result.get('top5', []))}")
            
            for i, item in enumerate(result.get('top5', []), 1):
                print(f"  {i}. {item['label']} (점수: {item['score']:.4f})")
            
            return result
        else:
            print(f"❌ 검색 실패: {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ 검색 중 오류: {e}")
        return None

def wait_for_model_ready(max_wait_time=300):
    """모델이 로딩될 때까지 대기"""
    print("⏳ CLIP 모델 로딩 대기 중...")
    
    start_time = time.time()
    while time.time() - start_time < max_wait_time:
        health = check_health()
        
        if health and health.get('model_loaded'):
            print("✅ 모델 로딩 완료!")
            return True
        
        print(f"⏱️  {int(time.time() - start_time)}초 경과... 모델 로딩 중...")
        time.sleep(10)  # 10초마다 체크
    
    print("⚠️  모델 로딩 시간 초과")
    return False

def main():
    print("🚀 DingQ API 테스트 시작!")
    print("=" * 50)
    
    # 1. 헬스 체크
    health = check_health()
    if not health:
        print("❌ 서비스에 접근할 수 없습니다.")
        return
    
    # 2. 모델 로딩 대기
    if not health.get('model_loaded'):
        if not wait_for_model_ready():
            print("❌ 모델 로딩 실패")
            return
    
    # 3. 이미지 검색 테스트
    print("\n🔍 이미지 검색 테스트")
    print("=" * 30)
    
    # 테스트 이미지 경로들
    test_images = [
        "testImages/sketch_1.png",
        "testImages/sketch_2.png",
        "testImages/ground_truth_1.png",
    ]
    
    for image_path in test_images:
        if os.path.exists(image_path):
            print(f"\n📸 테스트 이미지: {image_path}")
            result = test_image_search(image_path)
            if result:
                print("✅ 테스트 성공!")
            else:
                print("❌ 테스트 실패!")
            print("-" * 40)
        else:
            print(f"⚠️  이미지 파일이 없습니다: {image_path}")
    
    print("\n🎉 테스트 완료!")

if __name__ == "__main__":
    main() 