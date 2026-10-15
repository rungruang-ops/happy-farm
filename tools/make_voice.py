import asyncio, csv, pathlib
import edge_tts

ROOT = pathlib.Path(__file__).resolve().parent.parent
CONTENT, OUT = ROOT / "game/content", ROOT / "game/audio/voice"
VOICES = {"th": "th-TH-PremwadeeNeural", "en": "en-US-AnaNeural"}
PITCH = "+15Hz"

def rows(name):
    with open(CONTENT / name, encoding="utf-8-sig") as f:
        return list(csv.DictReader(f))

def lines():
    for lang in VOICES:
        for r in rows("phrases.csv"):
            yield f"{r['id']}_{lang}", lang, r[f"text_{lang}"]
        for r in rows("levels.csv"):
            yield f"lvl_{r['id']}_{lang}", lang, r[f"title_{lang}"]
        for r in rows("items.csv"):
            yield f"item_{r['id']}_{lang}", lang, r[f"name_{lang}"]

async def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for name, lang, text in lines():
        out = OUT / f"{name}.mp3"
        if out.exists() or not text.strip():
            continue
        await edge_tts.Communicate(text, VOICES[lang], pitch=PITCH).save(str(out))
        print("✓", name)

asyncio.run(main())
