import argparse, base64, csv, io, pathlib
from concurrent.futures import ThreadPoolExecutor
from PIL import Image, ImageOps

ROOT = pathlib.Path(__file__).resolve().parent.parent
GAME, TOOLS = ROOT, ROOT / "tools"
CONTENT, RAW = ROOT / "content", TOOLS / "raw"
REF = TOOLS / "ref" / "bryan_sheet.png"

MODEL = "gpt-image-1"
QUALITY = "medium"
WORKERS = 3
LANCZOS = Image.Resampling.LANCZOS

KINDS = {
    "ref":  dict(out=TOOLS / "ref",      gen="1536x1024", mode="raw"),
    "char": dict(out=ROOT / "art/chars", gen="1024x1536", mode="cut",    box=(800, 1200)),
    "item": dict(out=ROOT / "art/items", gen="1024x1024", mode="square", box=(512, 512)),
    "prop": dict(out=ROOT / "art/props", gen="1536x1024", mode="cut",    box=(1024, 768)),
    "ui":   dict(out=ROOT / "art/ui",    gen="1024x1024", mode="cut",    box=(1024, 768)),
    "bg":   dict(out=ROOT / "art/bg",    gen="1536x1024", mode="cover",  box=(1920, 1080)),
}
BG = "plain flat light-blue background"
MATCH = "Match the art style of the attached reference image exactly."
PROMPTS = {
    "ref":  "{p}.\n{char}\nPlain light gray background, no ground shadow.\n{style}",
    "char": "Use the attached character reference exactly (same face, colors, outfit, proportions).\n"
            "{char}\nPose: {p}.\nSingle character, full body, centered, {bg}, no ground shadow.\n{style}",
    "item": "{match}\nA single {p}, game item icon, centered, three-quarter front view, "
            "fills about 80% of the frame, {bg}, no shadow, no text.\n{style}",
    "prop": "{match}\n{p}, game prop, front view, centered, {bg}, no text, no labels.\n{style}",
    "ui":   "{match}\n{p}, game UI element, front view, centered, symmetrical, {bg}, "
            "no text, no symbols.\n{style}",
    "bg":   "{match} Do NOT include the character from the reference.\n"
            "Wide 16:9 game background, {p}. No characters, no animals, no text, no UI.\n{style}",
}

_client = _session = None
def client():
    global _client
    if _client is None:
        from openai import OpenAI
        _client = OpenAI()
    return _client

def session():
    global _session
    if _session is None:
        from rembg import new_session
        _session = new_session("isnet-general-use")
    return _session

def setup_godot_files():
    for p in CONTENT.glob("*.csv"):
        imp = p.with_suffix(".csv.import")
        if not imp.exists():
            imp.write_text('[remap]\n\nimporter="keep"\n', encoding="utf-8")

def load_jobs():
    jobs = []
    with open(CONTENT / "items.csv", encoding="utf-8-sig") as f:
        jobs += [dict(id=r["id"], kind="item", prompt=r["prompt"]) for r in csv.DictReader(f)]
    with open(CONTENT / "art.csv", encoding="utf-8-sig") as f:
        jobs += [dict(id=r["id"], kind=r["kind"], prompt=r["prompt"]) for r in csv.DictReader(f)]
    return jobs

def call_api(prompt, size, use_ref):
    if use_ref:
        with open(REF, "rb") as f:
            r = client().images.edit(model=MODEL, image=[f], prompt=prompt, size=size, quality=QUALITY)
    else:
        r = client().images.generate(model=MODEL, prompt=prompt, size=size, quality=QUALITY)
    return base64.b64decode(r.data[0].b64_json)

def cutout(raw):
    from rembg import remove
    img = Image.open(io.BytesIO(remove(raw, session=session()))).convert("RGBA")
    box = img.getchannel("A").point(lambda a: 255 if a > 10 else 0).getbbox()
    return img.crop(box) if box else img

def fit(img, box, square, pad=0.06):
    w, h = box
    img = img.copy()
    img.thumbnail((int(w * (1 - 2 * pad)), int(h * (1 - 2 * pad))), LANCZOS)
    if not square:
        return img
    canvas = Image.new("RGBA", box, (0, 0, 0, 0))
    canvas.paste(img, ((w - img.width) // 2, (h - img.height) // 2), img)
    return canvas

def process(raw, cfg):
    if cfg["mode"] == "raw":
        return Image.open(io.BytesIO(raw))
    if cfg["mode"] == "cover":
        return ImageOps.fit(Image.open(io.BytesIO(raw)).convert("RGB"), cfg["box"], LANCZOS)
    return fit(cutout(raw), cfg["box"], square=cfg["mode"] == "square")

def run(job, redo):
    cfg = KINDS[job["kind"]]
    out = cfg["out"] / f"{job['id']}.png"
    raw_path = RAW / f"{job['id']}.png"
    if redo:
        raw_path.unlink(missing_ok=True)
        out.unlink(missing_ok=True)
    if out.exists():
        return f"·  {job['id']}"
    if not raw_path.exists():
        prompt = PROMPTS[job["kind"]].format(
            p=job["prompt"], char=CHAR, style=STYLE, bg=BG, match=MATCH)
        raw_path.write_bytes(call_api(prompt, cfg["gen"], use_ref=job["kind"] != "ref"))
    cfg["out"].mkdir(parents=True, exist_ok=True)
    process(raw_path.read_bytes(), cfg).save(out)
    return f"✓  {job['id']}"

def safe_run(job, redo):
    try:
        return run(job, redo)
    except Exception as e:
        return f"✗  {job['id']}: {e}"

def write_review():
    parts = []
    for kind, cfg in KINDS.items():
        files = sorted(cfg["out"].glob("*.png"))
        if files:
            cards = "".join(f'<figure><img src="{p.resolve().as_uri()}">' 
                            f'<figcaption>{p.stem}</figcaption></figure>' for p in files)
            parts.append(f"<h2>{kind} ({len(files)})</h2><div class=g>{cards}</div>")
    (TOOLS / "review.html").write_text(f"""<!doctype html><meta charset=utf-8>
<style>body{{font-family:sans-serif;background:#7fbf5a;margin:20px}}
.g{{display:flex;flex-wrap:wrap;gap:12px}}
figure{{margin:0;background:#ffffff40;padding:8px;border-radius:12px;text-align:center}}
img{{height:160px;max-width:300px;object-fit:contain}}</style>
<p>ภาพไหนไม่เข้าชุด → <b>make redo ID=ชื่อภาพ</b></p>{''.join(parts)}""", encoding="utf-8")

def main():
    global STYLE, CHAR
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", default="")
    ap.add_argument("--redo", action="store_true")
    ap.add_argument("--setup", action="store_true")
    a = ap.parse_args()
    setup_godot_files()
    if a.setup:
        return print("✓ เตรียมไฟล์ให้ Godot แล้ว")

    STYLE = (CONTENT / "style.txt").read_text(encoding="utf-8").strip()
    CHAR = (CONTENT / "character.txt").read_text(encoding="utf-8").strip()
    RAW.mkdir(parents=True, exist_ok=True)
    jobs = load_jobs()

    if not REF.exists():
        for j in [j for j in jobs if j["kind"] == "ref"]:
            print(safe_run(j, False))
        print("\n→ เปิดดู tools/ref/bryan_sheet.png"
              "\n→ ยังไม่ชอบ: make redo ID=bryan_sheet | พอใจแล้ว: make assets อีกครั้ง")
        return

    if a.only:
        ids = set(a.only.split(","))
        jobs = [j for j in jobs if j["id"] in ids]
    client(); session()
    with ThreadPoolExecutor(WORKERS) as ex:
        for msg in ex.map(lambda j: safe_run(j, a.redo), jobs):
            print(msg)
    write_review()
    print("→ เปิด tools/review.html เพื่อตรวจภาพ")

if __name__ == "__main__":
    main()
