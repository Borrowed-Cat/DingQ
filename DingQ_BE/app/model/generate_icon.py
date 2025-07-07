import threading
import os
import queue
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
        # Gemini AI 클라이언트 생성 (환경변수 GOOGLE_API_KEY 사용)
        api_key = os.getenv("GOOGLE_API_KEY")
        if not api_key:
            raise ValueError("GOOGLE_API_KEY 환경변수가 설정되지 않았습니다.")
        
        client = genai.Client(api_key=api_key)
        user_text = f"이 아이콘은 '{input_text}'의 심볼입니다."

        # 현재 파일의 디렉토리 기준으로 이미지 경로 설정
        current_dir = os.path.dirname(os.path.abspath(__file__))
        image_total_path = os.path.join(current_dir, 'total_dingbat.png')
        image_total = Image.open(image_total_path)  # 기준 스타일 이미지

        response = client.models.generate_content(
            model="gemini-2.0-flash-preview-image-generation",
            contents=[prompt, user_text, input_image, image_total],
            config=types.GenerateContentConfig(
                response_modalities=['TEXT', 'IMAGE'],
                temperature=temperature
            ),
        )
        if response and response.candidates and len(response.candidates) > 0 and response.candidates[0].content:
            for part in response.candidates[0].content.parts: # type: ignore
                if part.inline_data is not None:
                    generated_image = Image.open(BytesIO(part.inline_data.data)) # type: ignore
                    result_queue.put((run_id, generated_image))
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
