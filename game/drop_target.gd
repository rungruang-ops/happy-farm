# game/drop_target.gd
extends Area2D
class_name DropTarget

signal dropped(item_id)

func _on_area_input_event(viewport, event, shape_idx):
	# placeholder for drop handling
	pass
