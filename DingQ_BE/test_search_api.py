#!/usr/bin/env python3
"""
DingQ Backend API Test Script
이미지 검색 API 테스트용 스크립트
"""

import requests
import json
import os
from pathlib import Path

# API 서버 URL
BASE_URL = "http://localhost:8000"

def test_health_check():
    """헬스체크 테스트"""
    print("🔍 헬스체크 테스트...")
    try:
        response = requests.get(f"{BASE_URL}/health")
        print(f"Status: {response.status_code}")
        print(f"Response: {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"❌ 헬스체크 실패: {e}")
        return False

def test_root_endpoint():
    """루트 엔드포인트 테스트"""
    print("\n🔍 루트 엔드포인트 테스트...")
    try:
        response = requests.get(f"{BASE_URL}/")
        print(f"Status: {response.status_code}")
        print(f"Response: {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"❌ 루트 엔드포인트 실패: {e}")
        return False

def test_image_search(image_path):
    """이미지 검색 테스트"""
    print(f"\n🔍 이미지 검색 테스트: {image_path}")
    
    if not os.path.exists(image_path):
        print(f"❌ 이미지 파일을 찾을 수 없습니다: {image_path}")
        return False
    
    try:
        with open(image_path, 'rb') as f:
            files = {'image': (os.path.basename(image_path), f, 'image/png')}
            response = requests.post(f"{BASE_URL}/search", files=files)
        
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"Top 5 결과:")
            for i, item in enumerate(result.get('top5', []), 1):
                print(f"  {i}. {item['label']} (score: {item['score']}, url: {item.get('url', 'N/A')})")
            
            print(f"처리 시간: {result.get('processing_time', 'N/A'):.3f}초")
            print(f"전체 결과 수: {result.get('total_results', 'N/A')}")
            return True
        else:
            print(f"❌ 검색 실패: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ 이미지 검색 실패: {e}")
        return False

def test_stats_endpoint():
    """통계 엔드포인트 테스트"""
    print("\n🔍 통계 엔드포인트 테스트...")
    try:
        response = requests.get(f"{BASE_URL}/stats")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            stats = response.json()
            print(f"전체 스케치 수: {stats.get('total_sketches', 0)}")
            print(f"고유 사용자 수: {stats.get('unique_users', 0)}")
            print(f"모델 상태: {stats.get('model_status', 'unknown')}")
            return True
        else:
            print(f"❌ 통계 조회 실패: {response.text}")
            return False
    except Exception as e:
        print(f"❌ 통계 엔드포인트 실패: {e}")
        return False

def test_user_sketches(user_ip="127.0.0.1"):
    """사용자 스케치 히스토리 테스트"""
    print(f"\n🔍 사용자 스케치 히스토리 테스트: {user_ip}")
    try:
        response = requests.get(f"{BASE_URL}/sketches/{user_ip}")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            history = response.json()
            print(f"사용자 IP: {history.get('user_ip', 'N/A')}")
            print(f"전체 스케치 수: {history.get('total_sketches', 0)}")
            
            sketches = history.get('sketches', [])
            if sketches:
                print("최근 스케치:")
                for i, sketch in enumerate(sketches[:3], 1):
                    print(f"  {i}. {sketch['filename']} ({sketch['file_size']} bytes)")
                    print(f"     생성일: {sketch['created_at']}")
                    if sketch.get('search_results'):
                        top_result = sketch['search_results'].get('top5', [])
                        if top_result:
                            print(f"     최고 매치: {top_result[0]['label']} (score: {top_result[0]['score']})")
            else:
                print("스케치 히스토리가 없습니다.")
            return True
        else:
            print(f"❌ 스케치 히스토리 조회 실패: {response.text}")
            return False
    except Exception as e:
        print(f"❌ 사용자 스케치 테스트 실패: {e}")
        return False

def main():
    print("=== DingQ API 테스트 시작 ===")
    
    # 기본 연결 테스트
    if not test_health_check():
        print("❌ 서버 연결 실패. 서버가 실행 중인지 확인하세요.")
        return
    
    test_root_endpoint()
    
    # 이미지 검색 테스트
    test_images = [
        "../../testImages/sketch_1.png",
        "../../testImages/sketch_2.png"
    ]
    
    for image_path in test_images:
        if os.path.exists(image_path):
            test_image_search(image_path)
            break
    else:
        print("❌ 테스트 이미지를 찾을 수 없습니다.")
        print("다음 경로에 테스트 이미지를 준비하세요:")
        for path in test_images:
            print(f"  - {path}")
    
    # 통계 및 히스토리 테스트
    test_stats_endpoint()
    test_user_sketches()
    
    print("\n=== 테스트 완료 ===")

if __name__ == "__main__":
    main() 