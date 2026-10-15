GODOT ?= godot
PY    ?= python

setup:
	$(PY) tools/make_assets.py --setup

assets:
	$(PY) tools/make_assets.py
	$(PY) tools/make_voice.py

redo:
	$(PY) tools/make_assets.py --redo --only $(ID)

import: setup
	$(GODOT) --headless --path game --import

run: import
	$(GODOT) --path game

release: import
	mkdir -p build/web build/android
	$(GODOT) --headless --path game --export-release "Web" ../build/web/index.html
	$(GODOT) --headless --path game --export-release "Android" ../build/android/happyfarm.apk

.PHONY: setup assets redo import run release
