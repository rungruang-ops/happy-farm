# Happy Farm — Educational Game (Godot 4)

This branch (feature/factory-setup) contains the initial project skeleton, content templates, autoload stubs, core/game/ui/screen placeholders, and basic tools to generate assets and voice.

Quick start

1. Setup Python environment
   - Copy .env.example to .env and fill API keys (do NOT commit .env)
   - make setup

2. Generate assets and voice
   - make assets
   - make voice

3. Run Godot
   - make run

Secrets / API keys
- Use .env for local development (.env is ignored). Example variables are in .env.example.
- For CI or automation, add secrets to GitHub repository Settings → Secrets and reference them in workflows.

Architecture
- content/: CSV and text files are the single source of truth for items, levels, phrases, and art prompts.
- autoload/: global singletons loaded by Godot.
- tools/: Python helper scripts to generate images and voices.

Contributing
- All work for this feature branch will be made here. Open PRs to merge into main when ready.
