# Autoload: game_state.gd
extends Node
class_name GameState

signal level_changed(new_level_id)

const SAVE_PATH := "user://game_state.json"

var current_level_id: String = ""
var score: int = 0
var stars: int = 0
var lives: int = 3
var unlocked_levels: Array = []

func _ready() -> void:
	load()

func set_level(level_id: String) -> void:
	current_level_id = level_id
	emit_signal("level_changed", level_id)
	save()

func reset() -> void:
	current_level_id = ""
	score = 0
	stars = 0
	lives = 3
	unlocked_levels = []
	save()

func add_score(delta: int) -> void:
	score += delta
	save()

func add_star() -> void:
	stars += 1
	save()

func lose_life() -> void:
	lives = max(lives - 1, 0)
	save()

func unlock_level(level_id: String) -> void:
	if not level_id in unlocked_levels:
		unlocked_levels.append(level_id)
		save()

func is_unlocked(level_id: String) -> bool:
	return level_id in unlocked_levels

# Persistence
func save() -> void:
	var data := {
		"current_level_id": current_level_id,
		"score": score,
		"stars": stars,
		"lives": lives,
		"unlocked_levels": unlocked_levels,
	}
	var json := JSON.print(data)
	var f := FileAccess.open(SAVE_PATH, FileAccess.ModeFlags.WRITE)
	if not f:
		push_warning("GameState: cannot open save file for writing: %s" % SAVE_PATH)
		return
	f.store_string(json)
	f.close()

func load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.ModeFlags.READ)
	if not f:
		push_warning("GameState: cannot open save file for reading: %s" % SAVE_PATH)
		return
	var text := f.get_as_text()
	f.close()
	var res := JSON.parse(text)
	if res.error != OK:
		push_warning("GameState: failed to parse save file: %s" % str(res.error))
		return
	var obj := res.result
	current_level_id = obj.get("current_level_id", "")
	score = int(obj.get("score", 0))
	stars = int(obj.get("stars", 0))
	lives = int(obj.get("lives", 3))
	unlocked_levels = obj.get("unlocked_levels", [])
