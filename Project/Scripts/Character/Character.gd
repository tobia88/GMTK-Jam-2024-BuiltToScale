extends CharacterBody3D

class_name Character

class JumpRequest:
	var is_power_jump: bool = false
	var is_consuming_lvl: bool = false

	func _init(p_is_power_jump: bool = false, p_is_consuming_lvl: bool = false):
		is_power_jump = p_is_power_jump
		is_consuming_lvl = p_is_consuming_lvl


const move_speed := 5.0
const airborne_move_speed_multiplier := 0.5
const jump_height := 1.5
const power_jump_height_multiplier := 1.5

@export var gravity_scale := 2.0

@onready var animation_tree := $AnimationTree

var input_dir := Vector2.ZERO

var _scale_lvl := 1
var scale_lvl: int:
	get:
		return _scale_lvl
	set(value):
		_scale_lvl = value
		update_scale()

var camera : Camera3D:
	get:
		return %Camera3D

var jump_requests: Array[JumpRequest]

var is_launching := false
var launch_request := 0.0

var should_consume_lvl := false
var should_jump := false
var is_power_jump := false

var target_quat := Quaternion.IDENTITY
@onready var mesh : Node3D = %Mesh

class AnimParams:
	var is_on_floor: bool = false
	var is_falling: bool = false
	var is_running: bool = false
	var scale_add_value: float = 0.0
	var scale_value: float = 0.0

@onready var anim_params: AnimParams = AnimParams.new()


func get_merged_gravity() -> Vector3:
	return get_gravity() * gravity_scale


func _process(delta: float) -> void:
	_collect_animation_params(delta)
	_update_animation_tree()


func _physics_process(delta: float) -> void:
	_handle_input(delta)
	_process_movement(delta)
	_process_rotation(delta)
	_process_consume_lvl()
	_cleanup_requests()
	_debug_draw()


func launch_by_target_height(target_height: float) -> void:
	launch_request = target_height


func dead() -> void:
	mesh.visible = false


func _collect_animation_params(delta: float) -> void:
	anim_params.is_on_floor = is_on_floor()
	anim_params.is_falling = velocity.y < 0.0
	anim_params.is_running = anim_params.is_on_floor and (Vector2(velocity.x, velocity.z).length() > 0)
	anim_params.scale_add_value = 1.0 if scale_lvl > 0.0 else 0.0
	
	var target_value = (scale_lvl - 1.0)
	const scale_smooth_speed = 5.0
	anim_params.scale_value = move_toward(anim_params.scale_value, target_value, delta * scale_smooth_speed)


func _update_animation_tree() -> void:
	animation_tree["parameters/StateMachine/conditions/is_on_air"] = !anim_params.is_on_floor
	animation_tree["parameters/StateMachine/conditions/is_on_floor"] = anim_params.is_on_floor
	
	animation_tree["parameters/StateMachine/SM_Floor/conditions/is_idle"] = !anim_params.is_running
	animation_tree["parameters/StateMachine/SM_Floor/conditions/is_running"] = anim_params.is_running
	
	animation_tree["parameters/StateMachine/SM_Air/conditions/is_falling"] = anim_params.is_falling
	animation_tree["parameters/StateMachine/SM_Air/conditions/is_rising"] = !anim_params.is_falling
	
	animation_tree["parameters/Add_Scale/add_amount"] = anim_params.scale_add_value
	animation_tree["parameters/BS_Scale/blend_position"] = anim_params.scale_value


func _handle_input(delta: float) -> void:
	input_dir = Input.get_vector("move_left", "move_right", "move_back", "move_forward")
	_handle_jump_input()


func _handle_jump_input() -> void:
	if not Input.is_action_just_pressed("jump"):
		return

	if is_on_floor():
		should_jump = true
		is_power_jump = false
	else:
		if scale_lvl <= 1:
			return

		should_jump = true
		is_power_jump = true
		
	if should_jump:
		if is_power_jump:
			$AudioStreamPlayer_Jump_Power.play()
		else:
			$AudioStreamPlayer_Jump.play()


func _process_movement(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_merged_gravity() * delta

	_apply_external_forces()

	var move_dir := Vector3.ZERO
	if not input_dir.is_zero_approx():
		move_dir = camera.global_basis.x * input_dir.x + -camera.global_basis.z * input_dir.y
		move_dir.y = 0.0
		move_dir = move_dir.normalized()

	velocity.x = move_dir.x * move_speed
	velocity.z = move_dir.z * move_speed

	if move_and_slide():
		_process_collision()


func _process_rotation(delta: float) -> void:
	var target_dir_2d = Vector3(velocity.x, 0.0, velocity.z).normalized()
	if target_dir_2d.length() == 0.0:
		target_dir_2d = global_basis.z
	
	var target_yaw = atan2(target_dir_2d.x, target_dir_2d.z)
	target_quat = Quaternion.from_euler(Vector3(0.0, target_yaw, 0.0))
	
	const rotate_smooth_spd := 10
	quaternion = quaternion.slerp(target_quat, 1.0 - exp(-delta * rotate_smooth_spd))


func _process_consume_lvl() -> void:
	if is_power_jump:
		scale_lvl -= 1
		update_scale()


func _apply_external_forces() -> void:
	if launch_request > 0.0:
		velocity.y = compute_jump_height(launch_request)

	elif Input.is_action_just_pressed("jump"):
		if is_on_floor():
			should_jump = true
			is_power_jump = false
		else:
			if scale_lvl > 1:
				should_jump = true
				is_power_jump = true

	if should_jump:
		var multiplier: float = 1.0 if not is_power_jump else power_jump_height_multiplier
		var target_jump_height: float = jump_height * multiplier
		var jump_velocity := compute_jump_height(target_jump_height)
		velocity.y = jump_velocity

	launch_request = 0.0


func compute_jump_height(target_height: float) -> float:
	return sqrt(2.0 * -get_merged_gravity().y * target_height)


func update_scale() -> void:
	# process scale
	const scale_bonus_per_lvl := 0.1
	scale = Vector3.ONE + Vector3.ONE * (scale_lvl - 1) * scale_bonus_per_lvl


func _process_collision() -> void:
	for i in get_slide_collision_count():
		var c := get_slide_collision(i).get_collider()
		if c is TargetStructure:
			GameManager.active_level.on_character_collide_structure(self, c as TargetStructure)


func _cleanup_requests() -> void:
	jump_requests.clear()

	should_jump = false
	is_power_jump = false


func _debug_draw() -> void:
	%DebugLabel3D.text = "Lvl=%d" % scale_lvl
