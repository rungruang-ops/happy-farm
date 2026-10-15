extends Node
class_name Catalog

# Catalog autoload — loads CSV files from content/ and exposes helper getters
# Usage (as autoload/singleton):
#   Catalog.get_items()
#   Catalog.get_item("item_apple")
#   Catalog.get_levels()
#   Catalog.get_level("level_1")
#   Catalog.get_phrases()
#   Catalog.get_phrase("p_welcome")
#   Catalog.get_art("apple_basic")

var items: Array = []
var levels: Array = []
var phrases: Array = []
var art: Dictionary = {}
var loaded: bool = false

func _ready() -> void:
	# auto-load on scene tree ready (if used as autoload)
	load_all()

func load_all() -> void:
	items = _load_csv_array("content/items.csv")
	levels = _load_csv_array("content/levels.csv")
	phrases = _load_csv_array("content/phrases.csv")
	var art_arr = _load_csv_array("content/art.csv")
	art = {}
	for a in art_arr:
		var key = a.get("art_key", "")
		if key != "":
			art[key] = a
	loaded = true
	print("[Catalog] loaded: items=%d levels=%d phrases=%d art=%d" % [items.size(), levels.size(), phrases.size(), art.size()])

func reload() -> void:
	load_all()

# Generic CSV loader that handles quoted fields and commas
func _load_csv_array(path: String) -> Array:
	if not FileAccess.file_exists(path):
		push_warning("Catalog: file not found: %s" % path)
		return []
	var f := FileAccess.open(path, FileAccess.ModeFlags.READ)
	if not f:
		push_warning("Catalog: unable to open %s" % path)
		return []
	var text := f.get_as_text()
	f.close()
	var lines := text.split('\n')
	if lines.size() == 0:
		return []
	var headers := _parse_csv_line(lines[0])
	for i in range(headers.size()):
		headers[i] = headers[i].strip_edges()
	var out := []
	for i in range(1, lines.size()):
		var line := lines[i].strip_edges()
		if line == "":
			continue
		var cols := _parse_csv_line(line)
		var obj := {}
		for j in range(min(headers.size(), cols.size())):
			obj[headers[j]] = cols[j].strip_edges()
		out.append(obj)
	return out

# Basic CSV line parser (supports quoted fields with commas and double-quote escaping)
func _parse_csv_line(line: String) -> Array:
	var res := []
	var cur := ""
	var in_quotes := false
	var i := 0
	while i < line.length():
		var c := line[i]
		if c == '"':
			if in_quotes and i + 1 < line.length() and line[i + 1] == '"':
				# escaped quote ""
				cur += '"'
				i += 1
			else:
				in_quotes = not in_quotes
			# don't add quote char
		elif c == ',' and not in_quotes:
			res.append(cur)
			cur = ""
		else:
			cur += c
		i += 1
	# append last
	res.append(cur)
	return res

# Convenience getters
func get_items() -> Array:
	return items.duplicate()

func get_item(item_id: String) -> Dictionary:
	for it in items:
		if it.has("id") and it["id"] == item_id:
			return it
		# support alternate key name
		if it.has("item_id") and it["item_id"] == item_id:
			return it
	return {}

func get_levels() -> Array:
	return levels.duplicate()

func get_level(level_id: String) -> Dictionary:
	for lv in levels:
		if lv.has("level_id") and lv["level_id"] == level_id:
			# parse targets into array for convenience
			var out = lv.duplicate()
			if out.has("targets"):
				out["targets_list"] = _parse_semicolon_list(out["targets"])
			return out
	return {}

func get_phrases() -> Array:
	return phrases.duplicate()

func get_phrase(phrase_id: String) -> Dictionary:
	for p in phrases:
		if p.has("phrase_id") and p["phrase_id"] == phrase_id:
			return p
	return {}

func get_art(art_key: String) -> Dictionary:
	if art.has(art_key):
		return art[art_key].duplicate()
	return {}

# Helpers
func _parse_semicolon_list(s: String) -> Array:
	if s == null or s == "":
		return []
	var parts := s.split(";")
	for i in range(parts.size()):
		parts[i] = parts[i].strip_edges()
	return parts
