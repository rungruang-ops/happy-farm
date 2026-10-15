# screens/complete_screen.gd
extends Control
class_name CompleteScreen

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://screens/level_select.tscn")
