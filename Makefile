# Makefile for happy-farm
.PHONY: setup assets voice redo run release

setup:
	python -m pip install --upgrade pip
	python -m pip install -r requirements.txt

assets:
	python tools/make_assets.py

voice:
	python tools/make_voice.py

redo:
	# regenerate assets and voice
	rm -rf art/* audio/voice/* || true
	make assets
	make voice

run:
	# Run Godot editor (requires godot 4 installed and on PATH)
	godot --path .

release:
	# Export presets should be configured in Godot editor. Example placeholder:
	@echo "Use Godot editor to export or configure export_presets.cfg"
