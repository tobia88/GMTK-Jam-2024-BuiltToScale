extends Node3D

class_name Level

enum LevelState {
	NONE,
	GAME_START,
	PLAYING,
	GAME_OVER,
	ENDED
}

var _level_state: LevelState = LevelState.NONE
var _pending_state: LevelState = LevelState.NONE
var level_state: LevelState:
	get:
		return _level_state
	set(value):
		_pending_state = value

var player_ctrl: PlayerCtrl

func _process(delta: float) -> void:
	if _pending_state != level_state:
		_enter_state(_pending_state)


func on_character_enter_building(character: Character, building: Building) -> void:
	print_debug("%s is entering %s" % [character.name, building.name])
	building.is_activated = true

	character.scale_lvl += 1
	character.launch_by_target_height(5.0)


func on_character_collide_structure(character: Character, structure: TargetStructure) -> void:
	if character.scale_lvl < structure.required_scale_lvl:
		character.dead()
	else:
		structure.dead()
	print_debug("%s is collide with %s" % [character.name, structure.name])


func _enter_state(new_state: LevelState) -> void:
	_level_state = new_state

	match(_level_state):
		LevelState.GAME_START: _on_game_start()
		
	print_debug("Enter: %s" % str(LevelState.keys()[_level_state]))


func _on_game_start() -> void:
	player_ctrl = preload("res://Game/PlayerCtrl.tscn").instantiate()
	add_child(player_ctrl)
	level_state = LevelState.PLAYING
