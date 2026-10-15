# game/draggable_item.gd
extends Node2D
class_name DraggableItem

var item_id: String

func _ready():
	set_process_input(true)

func _input(event):
	# implement drag behavior
	pass
