extends Node

var _active_level: Level
var active_level: Level:
	get:
		if not _active_level:
			_active_level = get_tree().get_first_node_in_group("level")
		return _active_level
	set(value):
		_active_level = active_level

func _ready() -> void:
	if active_level:
		active_level.level_state = Level.LevelState.GAME_START
