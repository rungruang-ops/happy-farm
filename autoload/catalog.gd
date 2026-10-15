# Autoload: catalog.gd
extends Node
class_name Catalog

# Simple loader for CSV content; in production, implement caching & validation
func _ready():
	pass

func load_items() -> Array:
	# TODO: implement CSV parsing using FileAccess
	return []
