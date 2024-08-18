extends Node3D

class_name PlayerCtrl

@export var character_template: PackedScene


var camera: Camera3D:
	get: return %Camera3D

var parent_level: Level


var _active_character: Character


func _ready() -> void:
	%SpringArm3D.spring_length = %Camera3D.position.z

	parent_level = get_parent() as Level
	assert(parent_level)
	parent_level.on_phase_state_changed.connect(_handle_on_phase_state_changed)
	parent_level.on_level_state_changed.connect(_handle_on_level_state_changed)


func spawn_character() -> Character:
	var starter : Node3D = get_tree().get_first_node_in_group("character_start")
	assert(starter)

	var new_character: Character = character_template.instantiate()
	parent_level.add_child(new_character)

	new_character.global_position = starter.global_position
	new_character.global_rotation = starter.global_rotation

	return new_character


func _handle_on_phase_state_changed(new_phase: Level.PhaseState) -> void:
	match(new_phase):
		Level.PhaseState.ROCK_AND_ROLL:
			_active_character = spawn_character()
			_update_camera()
			
	_update_ui()

func _handle_on_level_state_changed(new_state: Level.LevelState) -> void:
	_update_ui()


func _update_camera() -> void:
	camera.current = true

	if _active_character:
		_active_character.camera.current = true
		
		
func _update_ui() -> void:
	%GameUI.control_planning.visible = \
		parent_level.level_state == Level.LevelState.PLAYING and \
		parent_level.phase_state == Level.PhaseState.PLANNING

	%GameUI.control_level_cleared.visible = parent_level.level_state == Level.LevelState.LEVEL_CLEARED
