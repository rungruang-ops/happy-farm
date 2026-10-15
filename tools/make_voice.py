"""
tools/make_voice.py
Generate voice lines for phrases.csv using edge-tts.
See .env.example for configuration.
"""
import os
import csv
import asyncio
from dotenv import load_dotenv

load_dotenv()
VOICE = os.getenv('EDGE_TTS_VOICE', 'en-US-AriaNeural')
OUTPUT_DIR = os.getenv('VOICE_OUTPUT_DIR', 'audio/voice')

os.makedirs(OUTPUT_DIR, exist_ok=True)

async def synthesize(text, out_path):
    try:
        import edge_tts
    except Exception:
        print('edge-tts not installed; run pip install -r requirements.txt')
        return
    communicate = edge_tts.Communicate(text, VOICE)
    await communicate.save(out_path)

async def main():
    csv_path = os.path.join('content','phrases.csv')
    if not os.path.exists(csv_path):
        print('content/phrases.csv missing')
        return
    with open(csv_path, newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            pid = row.get('phrase_id')
            text = row.get('text')
            out = os.path.join(OUTPUT_DIR, f"{pid}.mp3")
            print(f"Generating voice for {pid} -> {out}")
            await synthesize(text, out)

if __name__ == '__main__':
    asyncio.run(main())
