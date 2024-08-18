extends Node

var level_template_arr: Array[PackedScene] = [
	preload("res://Levels/Level_0.tscn"),
	preload("res://Levels/Level_1.tscn"),
]

var _active_level: Level
var active_level: Level:
	get:
		_active_level = get_tree().current_scene as Level
		return _active_level
	set(value):
		_active_level = active_level


func _ready() -> void:
	active_level.level_state = Level.LevelState.GAME_START

func load_level(idx: int) -> Level:
	var new_lvl = level_template_arr[idx].instantiate() as Level
	assert(new_lvl)
	return new_lvl
