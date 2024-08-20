extends Node

var level_template_arr: Array[PackedScene] = [
	preload("res://Levels/Level_0.tscn"),
	preload("res://Levels/Level_1.tscn"),
	preload("res://Levels/Level_2.tscn"),
]


var _active_level: Level
var active_level: Level:
	get:
		_active_level = get_tree().current_scene as Level
		return _active_level
	set(value):
		_active_level = active_level
		

var level_idx := 0
var is_waiting_level_ready := false


func _ready() -> void:
	level_idx = 0
	is_waiting_level_ready = true
	start_game()
	
	
func _process(delta: float) -> void:
	if is_waiting_level_ready and active_level:
		start_game()
		
	if Input.is_action_just_pressed("next_level"):
		enter_next_level()


func load_level(idx: int) -> void:
	print_debug("Load Level %d" % idx)
	get_tree().change_scene_to_packed(level_template_arr[idx])
	is_waiting_level_ready = true


func is_level_ready() -> bool:
	return get_tree().current_scene != null


func enter_next_level() -> void:
	level_idx += 1
	load_level(level_idx)
	
	
func restart_level() -> void:
	get_tree().reload_current_scene()
	

func start_game() -> void:
	is_waiting_level_ready = false

	if active_level:
		active_level.level_state = Level.LevelState.GAME_START


func quit_game() -> void:
	get_tree().quit()
