extends Node3D

class_name Level

enum LevelState {
	NONE,
	GAME_START,
	PLAYING,
	GAME_OVER,
	LEVEL_CLEARED,
	END_LEVEL
}

enum PhaseState {
	NONE,
	PLANNING,
	ROCK_AND_ROLL,
	FAILED_THIS_ROUND
}

var _level_state: LevelState = LevelState.NONE
var _pending_state_arr: Array[LevelState]
var level_state: LevelState:
	get:
		return _level_state
	set(value):
		_pending_state_arr.append(value)

var _phase_state: PhaseState = PhaseState.NONE
var _pending_phase_arr: Array[PhaseState]
var phase_state: PhaseState:
	get:
		return _phase_state
	set(value):
		_pending_phase_arr.append(value)
		

var target_structure_count: int:
	get:
		return get_tree().get_node_count_in_group("target_structure")


var player_ctrl: PlayerCtrl

signal on_level_state_changed(new_state: LevelState)
signal on_phase_state_changed(new_state: PhaseState)

func _process(delta: float) -> void:
	_process_pending_states()
	_process_pending_phases()

	_process_phase_state(delta)


func on_character_enter_building(character: Character, building: Building) -> void:
	print_debug("%s is entering %s" % [character.name, building.name])
	building.is_activated = true

	character.scale_lvl += 1
	#character.launch_by_target_height(5.0)

func on_character_collide_structure(character: Character, structure: TargetStructure) -> void:
	if character.scale_lvl < structure.required_scale_lvl:
		character.dead()
	else:
		structure.dead()
	print_debug("%s is collide with %s" % [character.name, structure.name])


func _process_pending_states() -> void:
	while !_pending_state_arr.is_empty():
		var new_state: LevelState = _pending_state_arr.pop_front()
		if new_state != _phase_state:
			_enter_level_state(new_state)


func _process_pending_phases() -> void:
	while !_pending_phase_arr.is_empty():
		var new_state: PhaseState = _pending_phase_arr.pop_front()
		if new_state != _phase_state:
			_enter_phase_state(new_state)


func _process_phase_state(delta: float) -> void:
	match(phase_state):
		PhaseState.PLANNING: _on_process_planning_state(delta)
		PhaseState.ROCK_AND_ROLL: _on_process_rock_and_roll_state(delta)


func _on_process_planning_state(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		phase_state = PhaseState.ROCK_AND_ROLL


func _on_process_rock_and_roll_state(delta: float) -> void:
	if target_structure_count == 0:
		level_state = LevelState.LEVEL_CLEARED


func _enter_level_state(new_state: LevelState) -> void:
	_level_state = new_state

	match(_level_state):
		LevelState.GAME_START: _on_enter_level_state_game_start()
		LevelState.PLAYING: _on_enter_level_state_playing()
		LevelState.LEVEL_CLEARED: _on_enter_level_state_level_cleared()

	on_level_state_changed.emit(_level_state)
	print_debug("Enter Level State: %s" % str(LevelState.keys()[_level_state]))


func _on_enter_level_state_game_start() -> void:
	player_ctrl = preload("res://Game/PlayerCtrl.tscn").instantiate()
	add_child(player_ctrl)
	level_state = LevelState.PLAYING


func _on_enter_level_state_playing() -> void:
	phase_state = PhaseState.ROCK_AND_ROLL
	
	
func _on_enter_level_state_level_cleared() -> void:
	phase_state = PhaseState.NONE


func _enter_phase_state(new_state: PhaseState) -> void:
	_phase_state = new_state
	print_debug("Enter Phase State: %s" % str(PhaseState.keys()[_phase_state]))
	on_phase_state_changed.emit(_phase_state)


func _on_death_area_3d_body_entered(body: Node3D) -> void:
	phase_state = PhaseState.FAILED_THIS_ROUND
