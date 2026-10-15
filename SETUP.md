# Happy Farm Setup Guide

This project is designed for a Godot 4 educational game targeting young children, using a Python asset-generation pipeline and CSV/TXT content files as the single source of truth.

## 1. Prerequisites

- Python 3.11+
- Git
- Godot 4 installed and available on PATH (`godot` command)
- Optional: OpenAI API key for image generation via `tools/make_assets.py`
- Optional: GitHub PAT (`GH_PAT`) if you want automated branch/PR generation from Actions

## 2. Local setup

From the project root:

```bash
cp .env.example .env
# edit .env and fill in your required values
make setup
```

### Required environment values

Create a `.env` file and set values like:

```env
OPENAI_API_KEY=your_key_here
ASSETS_OUTPUT_DIR=art
VOICE_OUTPUT_DIR=audio/voice
EDGE_TTS_VOICE=en-US-AriaNeural
```

Important: do not commit `.env` to the repository.

## 3. The project architecture

```text
happy-farm/
├─ project.godot
├─ Makefile
├─ requirements.txt
├─ content/
│  ├─ items.csv
│  ├─ levels.csv
│  ├─ phrases.csv
│  ├─ art.csv
│  ├─ style.txt
│  ├─ character.txt
│  └─ avoid.txt
├─ autoload/
│  ├─ catalog.gd
│  ├─ game_state.gd
│  ├─ sfx.gd
│  ├─ juice.gd
│  └─ router.gd
├─ core/
│  └─ level_factory.gd
├─ game/
│  ├─ draggable_item.gd
│  ├─ drop_target.gd
│  └─ choice_card.gd
├─ ui/
│  ├─ theme_builder.gd
│  ├─ ui.gd
│  ├─ star_icon.gd
│  └─ mascot.gd
├─ screens/
│  ├─ title_screen.gd
│  ├─ level_select.gd
│  ├─ game_screen.gd
│  └─ complete_screen.gd
├─ art/
├─ audio/
│  ├─ voice/
│  ├─ sfx/
│  ├─ music/
│  └─ animals/
├─ tools/
│  ├─ make_assets.py
│  ├─ make_voice.py
│  └─ review.html
├─ ref/
├─ build/
└─ .github/workflows/
```

## 4. Useful commands

### Install Python dependencies

```bash
make setup
```

### Generate image assets

```bash
make assets
```

### Generate voice assets

```bash
make voice
```

### Regenerate everything

```bash
make redo
```

### Run Godot editor

```bash
make run
```

### Build/release (placeholder)

```bash
make release
```

## 5. GitHub Actions workflow

This repository includes workflows for:

- CI validation (`.github/workflows/ci.yml`)
- Manual asset generation (`.github/workflows/assets-and-voice.yml`)

### Secrets / variables

Use GitHub Environment or Repository Secrets:

- `GEN_AI`: OpenAI API key for image generation
- Optional `GH_PAT`: PAT for automated push/PR creation

If `GH_PAT` is not configured, the workflow still runs and generates artifacts, but it will not push generated files back to the repo automatically.

## 6. Manual review flow without GH_PAT

When you run the workflow without `GH_PAT`:

1. Go to GitHub Actions.
2. Select the workflow run.
3. Download the generated artifact zip.
4. Unzip it into the project directory locally.
5. Review generated files.
6. Commit and push manually from your machine.

Example:

```bash
git fetch origin
git switch -c assets/manual-review origin/feature/factory-setup
# copy downloaded files into art/ and audio/voice/
git add art audio/voice
git commit -m "chore: add generated assets"
git push -u origin assets/manual-review
```

## 7. Best practices

- Keep `content/*.csv` and `*.txt` as the single source of truth.
- Do not commit `.env` files.
- Keep generated assets in `art/` and `audio/voice/` but review them before shipping.
- Use GitHub Secrets or environment variables for API keys.
- Validate content changes with CI before merging.

## 8. Recommended next steps

- Create Godot scenes and gameplay logic.
- Add CSV parsing in `autoload/catalog.gd`.
- Implement the core level flow in `core/level_factory.gd`.
- Connect UI and screen transitions.
- Add sound and animation polish.
