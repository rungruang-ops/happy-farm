"""
tools/make_assets.py
Generate images for art keys defined in content/art.csv using OpenAI Image API and run rembg to remove backgrounds.
This script is a starting point and must be configured with environment variables (see .env.example).
"""
import os
import csv
from dotenv import load_dotenv

load_dotenv()
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
OUTPUT_DIR = os.getenv("ASSETS_OUTPUT_DIR", "art")

if OPENAI_API_KEY is None:
    print("OPENAI_API_KEY not set. Set it in .env or environment variables.")

os.makedirs(OUTPUT_DIR, exist_ok=True)

# Minimal CSV read
art_csv = os.path.join("content", "art.csv")
if os.path.exists(art_csv):
    with open(art_csv, newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            key = row.get('art_key')
            prompt = row.get('prompt') or ''
            filename = os.path.join(OUTPUT_DIR, f"{key}.png")
            print(f"[placeholder] Would generate image for {key} with prompt: {prompt} -> {filename}")
            # TODO: call OpenAI images API and optionally run rembg to remove background
else:
    print("content/art.csv not found; nothing to generate.")
