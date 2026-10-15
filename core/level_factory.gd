# core/level_factory.gd
extends Node
class_name LevelFactory

# LevelFactory is a data-oriented factory that turns CSV rows from content/levels.csv
# into a dictionary-based runtime representation for gameplay.

func create_level(level_id: String) -> Dictionary:
	var catalog = get_tree().root.get_node_or_null("Catalog")
	if catalog == null:
		catalog = preload("res://autoload/catalog.gd").new()
	if catalog and catalog.has_method("get_level"):
		var level = catalog.get_level(level_id)
		if level.is_empty():
			push_warning("LevelFactory: level not found: %s" % level_id)
			return {}
		return level
	push_warning("LevelFactory: Catalog autoload not available")
	return {}

func create_level_list() -> Array:
	var catalog = get_tree().root.get_node_or_null("Catalog")
	if catalog == null:
		catalog = preload("res://autoload/catalog.gd").new()
	if catalog and catalog.has_method("get_levels"):
		return catalog.get_levels()
	return []

func get_targets_for(level_data: Dictionary) -> Array:
	if level_data.is_empty():
		return []
	if level_data.has("targets_list"):
		return level_data["targets_list"]
	if level_data.has("targets"):
		var raw := String(level_data["targets"])
		if raw == "":
			return []
		var arr = raw.split(";")
		for i in range(arr.size()):
			arr[i] = arr[i].strip_edges()
		return arr
	return []

func validate_level(level_data: Dictionary) -> bool:
	if level_data.is_empty():
		return false
	if not level_data.has("level_id"):
		return false
	if not level_data.has("title"):
		return false
	return true
