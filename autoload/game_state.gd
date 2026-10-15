# Autoload: game_state.gd
extends Node
class_name GameState

var current_level_id: String = ""
var score: int = 0

func reset():
	current_level_id = ""
	score = 0
