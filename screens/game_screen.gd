# screens/game_screen.gd
extends Control
class_name GameScreen

@onready var title_label: Label = $VBox/TitleLabel
@onready var targets_container: VBoxContainer = $VBox/Targets
@onready var complete_button: Button = $VBox/CompleteButton

var level_data: Dictionary = {}

func _ready() -> void:
	# determine current level
	var level_id := GameState.current_level_id
	if level_id == "":
		var levels := LevelFactory.create_level_list()
		if levels.size() > 0:
			level_id = levels[0].get("level_id", "")
			GameState.set_level(level_id)
	# load level data
	level_data = LevelFactory.create_level(level_id)
	if title_label:
		title_label.text = level_data.get("title", "Level")
	_load_targets()
	if complete_button:
		complete_button.pressed.connect(_on_complete_pressed)

func _load_targets() -> void:
	if targets_container == null:
		return
	for child in targets_container.get_children():
		child.queue_free()
	var targets := LevelFactory.get_targets_for(level_data)
	for t in targets:
		var label := Label.new()
		label.text = "- " + str(t)
		targets_container.add_child(label)

func _on_complete_pressed() -> void:
	# simulate completion: award points/stars and unlock next level
	GameState.add_score(100)
	GameState.add_star()
	var levels := LevelFactory.create_level_list()
	for i in range(levels.size()):
		if levels[i].get("level_id", "") == level_data.get("level_id", ""):
			if i + 1 < levels.size():
				GameState.unlock_level(levels[i + 1].get("level_id", ""))
			break
	get_tree().change_scene_to_file("res://screens/complete_screen.tscn")
