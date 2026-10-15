extends Node

# Simple router stub to change scenes
func go_to(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
