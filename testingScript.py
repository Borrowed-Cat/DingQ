# scripts/batch_refine.py
import os, io, json, time, base64, requests
from dotenv import load_dotenv
from PIL import Image
import openai, google.generativeai as genai
import torch, torch.nn.functional as F
from transformers import CLIPModel, CLIPProcessor

# ── 0. API 키 로딩 ────────────────────────────────
load_dotenv()
openai.api_key = os.getenv("OPENAI_API_KEY")
genai.configure(api_key=os.getenv("GOOGLE_API_KEY"))

# ── 1. CLIP 임베딩 함수 ───────────────────────────
DEVICE = "cuda" if torch.cuda.is_available() else "cpu"
clip_model = CLIPModel.from_pretrained(
    "openai/clip-vit-base-patch32",
    torch_dtype=torch.float32,        # or float16
    use_safetensors=True               # safetensors 포맷 사용
).to(DEVICE)
clip_proc  = CLIPProcessor.from_pretrained("openai/clip-vit-base-patch32")

def emb(img: Image.Image):
    """PIL.Image → L2-normalized CLIP embedding"""
    t = clip_proc(images=img, return_tensors="pt").to(DEVICE)
    with torch.no_grad():
        v = clip_model.get_image_features(**t)
    return v / v.norm(p=2, dim=-1, keepdim=True)

# ── 2A. OpenAI – DALL·E 2 Variation ──────────────
def refine_openai(sketch_path: str):
    with open(sketch_path, "rb") as f:
        t0 = time.time()
        r = openai.images.create_variation(image=f, n=1, size="512x512")
    url  = r.data[0].url
    img  = Image.open(requests.get(url, stream=True).raw)
    return img, time.time() - t0


# ── 3. 배치 테스트 루프 ────────────────────────────
def run_batch(prompt_dict):
    ptxt = json.dumps(prompt_dict, ensure_ascii=False)
    for i in range(1, 6):
        sk = f"testImages/sketch_{i}.png"
        gt = f"testImages/ground_truth_{i}.png"
        print(f"\n[ sketch_{i} ]")

        oa_img, oa_t = refine_openai(sk)


        oa_img.save(f"testImages/generated_openai_{i}.png")


        emb_sk, emb_gt = emb(Image.open(sk)), emb(Image.open(gt))
        emb_oa= emb(oa_img)

        print(f"OpenAI  {oa_t:.2f}s  sk→gt:{F.cosine_similarity(emb_sk,emb_gt).item():.3f}"
              f"  oa→gt:{F.cosine_similarity(emb_oa,emb_gt).item():.3f}")

# ── 4. 실행 ────────────────────────────────────────
if __name__ == "__main__":
    prompt_json = json.dumps({
  "task"   : "webos_icon_refine",
  "brand"  : "LG webOS – Enact JS glyph set",
  "input_sketch_b64": "<<<BASE64_SKETCH>>>",          
  "output": {
    "format"      : "PNG",                           
    "size"        : "512x512",
    "transparent" : True
  },


  "style": {
    "look"     : "flat two-tone silhouette",         
    "stroke"   : { "width_pct": 8, "caps": "round" },
    "fill"     : "none",
    "fx"       : "no gradient | no shadow | no gloss",
    "corner_rt": "45deg or perfect circle arcs",
    "contrast" : "maximum"
  },


  "layout_rules": {
    "canvas_padding_pct" : 15,                     
    "align_center"       : True,
    "snap_geometry"      : [
      "straighten skewed lines to 0°, 45°, 90°",
      "replace rough curves with perfect circles / arcs",
      "mirror left/right for symmetry if sketch is unbalanced"
    ],
    "clean_noise"        : True,                      
    "complete_gaps"      : True                   
  },


  "interpretation_hints": {
    "infer_missing_parts" : True,         
    "context_examples": {
      "bluetooth"  : "overlapping pointed ovals rotated 45°",
      "edit"       : "pencil overlay on square page",
      "googleDrive": "equilateral triangle loop",
      "mute"       : "speaker + slash",
      "share"      : "node graph arrow"
    }
  },


  "negative_prompt": [
    "no gradients", "no drop-shadows", "no 3D bevel",
    "no multicolor", "no outer frame", "no watermark", "no text"
  ],


  "quality": "crisp vector-like edges, LG webOS launcher glyph quality"
}
)

    run_batch(prompt_json)
