# core/level_factory.gd
extends Node
class_name LevelFactory

func create_level(level_id: String) -> Node:
	# return a new level scene instance (placeholder)
	var node := Node.new()
	node.name = level_id
	return node
