# screens/title_screen.gd
extends Control
class_name TitleScreen

signal play_pressed

@onready var play_button: Button = $PlayButton

func _ready() -> void:
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	else:
		push_warning("TitleScreen: missing PlayButton node")

func _on_play_pressed() -> void:
	emit_signal("play_pressed")
	get_tree().change_scene_to_file("res://screens/level_select.tscn")
