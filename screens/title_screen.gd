# screens/title_screen.gd
extends Control
class_name TitleScreen

func _on_play_pressed():
	get_tree().change_scene_to_file("res://screens/level_select.tscn")
