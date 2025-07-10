import threading
import os
import queue
import base64
from io import BytesIO

from google import genai
from google.genai import types
from PIL import Image

# 프롬프트 설정
prompt = """
[목표 및 스타일 학습]
내가 그린 손그림을, 아래 제공된 전체 심볼 이미지의 스타일을 적용해서 픽토그램을 생성해줘.  
실제 선, 비율, 디테일은 무시하고 전체 심볼 이미지의 스타일 가이드에 따라 재해석할 것.

[요구사항]
1) 전체 심볼 이미지에서 파악한 스타일을 적용할 것. 
2) 배경은 반드시 흰색, 선은 검은색만 사용할 것.  
3) 깔끔하고 직관적인 픽토그램 디자인이어야 함.  
4) 손그림의 선을 절대 그대로 사용하지 않고, 전체 심볼 이미지의 일관된 선 스타일로만 재구성하라.
5) 전체 심볼 이미지의 스타일을 최우선으로 고려할 것.

[출력 형식]  
- 최종 결과물은 변환된 픽토그램 이미지를 이미지 파일 형태로 반환해줘.  
- 아이콘 내에 어떠한 문자나 텍스트도 포함하지 말 것.  

요구사항에 명시된 사항을 다시 한 번 점검하여 확실한 이해를 하고 생성할 것.
"""

def generate_icon(run_id, input_text, input_image, result_queue, temperature):
    try:
        client = genai.Client()
        user_text = f"이 아이콘은 '{input_text}'의 심볼입니다."

        # 현재 파일의 디렉토리를 기준으로 절대 경로 생성
        current_dir = os.path.dirname(os.path.abspath(__file__))
        total_dingbat_path = os.path.join(current_dir, 'total_dingbat.png')
        image_total = Image.open(total_dingbat_path)  # 기준 스타일 이미지

        response = client.models.generate_content(
            model="gemini-2.0-flash-preview-image-generation",
            contents=[prompt, user_text, input_image, image_total],
            config=types.GenerateContentConfig(
                response_modalities=['TEXT', 'IMAGE'],
                temperature=temperature
            ),
        )
        if response and response.candidates and len(response.candidates) > 0 and response.candidates[0].content:
            has_image = False
            for part in response.candidates[0].content.parts: # type: ignore
                if part.inline_data is not None:
                    has_image = True
                    try:
                        # 이미지 데이터 검증 및 안전한 변환
                        image_data = part.inline_data.data # type: ignore
                        mime_type = getattr(part.inline_data, 'mime_type', 'unknown') # type: ignore
                        print(f"[Run {run_id}] 이미지 데이터 수신: {len(image_data) if image_data else 0} bytes, MIME: {mime_type}")
                        
                        if image_data and len(image_data) > 0:
                            # 처음 몇 바이트를 확인해서 이미지 포맷 추정
                            if len(image_data) >= 8:
                                header = image_data[:8]
                                print(f"[Run {run_id}] 파일 헤더: {header.hex()}")
                                
                                # Base64 인코딩된 데이터인지 확인 (iVBORw로 시작하면 Base64 PNG)
                                if header == b'iVBORw0K':
                                    print(f"[Run {run_id}] Base64 인코딩된 PNG 데이터 감지됨")
                                    try:
                                        # Base64 디코딩
                                        decoded_data = base64.b64decode(image_data)
                                        print(f"[Run {run_id}] Base64 디코딩 완료: {len(decoded_data)} bytes")
                                        image_data = decoded_data
                                        # 디코딩된 헤더 확인
                                        decoded_header = image_data[:8]
                                        print(f"[Run {run_id}] 디코딩된 헤더: {decoded_header.hex()}")
                                    except Exception as decode_error:
                                        print(f"[Run {run_id}] Base64 디코딩 실패: {decode_error}")
                                        continue
                                
                                # PNG 헤더 확인 (89 50 4E 47 0D 0A 1A 0A)
                                if image_data[:8].startswith(b'\x89PNG\r\n\x1a\n'):
                                    print(f"[Run {run_id}] PNG 포맷 감지됨")
                                # JPEG 헤더 확인 (FF D8)
                                elif image_data[:8].startswith(b'\xFF\xD8'):
                                    print(f"[Run {run_id}] JPEG 포맷 감지됨")
                                # WEBP 헤더 확인
                                elif b'WEBP' in image_data[:12]:
                                    print(f"[Run {run_id}] WEBP 포맷 감지됨")
                                else:
                                    print(f"[Run {run_id}] 알 수 없는 이미지 포맷")
                            
                            image_bytes = BytesIO(image_data)
                            image_bytes.seek(0)  # 포인터를 처음으로 이동
                            generated_image = Image.open(image_bytes)
                            # 이미지가 정상적으로 로드되었는지 확인
                            generated_image.verify()
                            # verify() 후에는 이미지를 다시 로드해야 함
                            image_bytes.seek(0)
                            generated_image = Image.open(image_bytes)
                            print(f"[Run {run_id}] 이미지 성공적으로 로드됨: {generated_image.size}, 모드: {generated_image.mode}")
                            result_queue.put((run_id, generated_image))
                            return  # 성공 시 즉시 반환
                        else:
                            print(f"[Run {run_id}] 빈 이미지 데이터 수신")
                    except Exception as img_error:
                        print(f"[Run {run_id}] 이미지 처리 오류: {img_error}")
                        print(f"[Run {run_id}] 오류 타입: {type(img_error).__name__}")
                elif hasattr(part, 'text') and part.text:
                    print(f"[Run {run_id}] API 텍스트 응답: {part.text[:100]}...")
            
            if not has_image:
                print(f"[Run {run_id}] 응답에 이미지 데이터가 없습니다.")
        else:
            print(f"[Run {run_id}] 응답이 비어있거나 올바르지 않습니다.")
            result_queue.put((run_id, None))

    except Exception as e:
        print(f"[Run {run_id}] 오류 발생: {e}")
        result_queue.put((run_id, None))


def generate_with_retries(input_text, input_image, temperature=0.5, target_count=5, max_retries=5):
    result_queue = queue.Queue()
    total_generated = 0
    attempt = 1
    generated_images = []

    while total_generated < target_count and attempt <= max_retries:
        needed = target_count - total_generated
        print(f"[generate] 이미지 {needed}개 생성 필요, 시도 {attempt}/{max_retries}")

        threads = []
        for i in range(1, needed + 1):
            t = threading.Thread(
                target=generate_icon,
                args=(i, input_text, input_image, result_queue, temperature)
            )
            threads.append(t)
            t.start()

        for t in threads:
            t.join()

        success_count = 0
        while not result_queue.empty():
            run_id, img = result_queue.get()
            if img:
                # 이미지를 BytesIO로 변환
                img_bytes = BytesIO()
                img.save(img_bytes, format='PNG')
                img_bytes.seek(0)
                generated_images.append(img_bytes)
                total_generated += 1
                print(f"[generate] 이미지 생성 완료 ({total_generated}/{target_count})")
                success_count += 1
            else:
                print(f"[generate] 이미지 생성 실패")

        attempt += 1

    if total_generated < target_count:
        print(f"[generate] 최종적으로 {target_count}개 생성하지 못했습니다. 생성된 이미지 수: {total_generated}")
    else:
        print(f"[generate] 이미지 {target_count}개 생성 완료!")

    return generated_images

def main():
    #INPUT 
    user_input_text = input("변환할 심볼 이름을 입력하세요: ") # 사용자가 작성한 심볼 설명
    user_input_image_path = "gen_test.png" # 사용자가 그린 손그림
    temperature = 0.5  # 필요 시 사용자 입력으로 변경

    if not os.path.isfile(user_input_image_path):
        print(f"오류: 파일을 찾을 수 없습니다 - {user_input_image_path}")
        return

    image = Image.open(user_input_image_path)

    generated_images = generate_with_retries(user_input_text, image, temperature, target_count=5, max_retries=5)
    print(f"총 {len(generated_images)}개의 이미지가 BytesIO로 생성되었습니다.")

    # PIL 이미지로 열어 확인해보기
    # img_bytesio = generated_images[0]  # <_io.BytesIO object at ...>
    # image = Image.open(img_bytesio)
    # image.show() 

    return generated_images

if __name__ == "__main__":
    main()
