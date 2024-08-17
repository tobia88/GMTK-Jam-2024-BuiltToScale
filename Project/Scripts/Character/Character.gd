extends CharacterBody3D

class_name Character

class JumpRequest:
	var is_power_jump: bool = false
	var is_consuming_lvl: bool = false

	func _init(p_is_power_jump: bool = false, p_is_consuming_lvl: bool = false):
		is_power_jump = p_is_power_jump
		is_consuming_lvl = p_is_consuming_lvl


const move_speed := 25.0
const jump_height := 2.0
@export var gravity_scale := 10.0

var input_dir := Vector2.ZERO

var _scale_lvl := 1
var scale_lvl: int:
	get:
		return _scale_lvl
	set(value):
		_scale_lvl = value
		update_scale()

@onready var camera := %Camera3D

var jump_requests: Array[JumpRequest]

var is_launching := false
var launch_request := 0.0

var should_consume_lvl := false

func get_merged_gravity() -> Vector3:
	return get_gravity() * gravity_scale


func _process(delta: float) -> void:
	handle_input(delta)
	process_movement(delta)
	process_consume_lvl()
	cleanup_requests()


func handle_input(delta: float) -> void:
	input_dir = Input.get_vector("move_left", "move_right", "move_back", "move_forward")

func process_movement(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_merged_gravity() * delta

	apply_external_forces()

	var move_dir := Vector3.ZERO
	if not input_dir.is_zero_approx():
		move_dir = camera.global_basis.x * input_dir.x + -camera.global_basis.z * input_dir.y
		move_dir.y = 0.0
		move_dir = move_dir.normalized()

	velocity.x = move_dir.x * move_speed
	velocity.z = move_dir.z * move_speed

	if move_and_slide():
		process_collision()


func process_consume_lvl() -> void:
	if should_consume_lvl:
		scale_lvl -= 1
		update_scale()
		should_consume_lvl = false


func apply_external_forces() -> void:
	if launch_request > 0.0:
		velocity.y = compute_jump_height(launch_request)

	elif Input.is_action_just_pressed("jump"):
		var should_jump = is_on_floor() or scale_lvl > 1
		should_consume_lvl = should_jump and !is_on_floor()

		if should_jump:
			var jump_velocity := compute_jump_height_by_lvl()
			velocity.y = jump_velocity

	launch_request = 0.0


func compute_jump_height_by_lvl() -> float:
	const base_jump_height := 2.0
	var target_jump_height = base_jump_height * scale_lvl
	return compute_jump_height(base_jump_height)


func compute_jump_height(target_height: float) -> float:
	return sqrt(2.0 * -get_merged_gravity().y * target_height)


func update_scale() -> void:
	# process scale
	const scale_bonus_per_lvl := 0.5
	scale = Vector3.ONE + Vector3.ONE * scale_lvl * scale_bonus_per_lvl


func launch_by_target_height(target_height: float) -> void:
	launch_request = target_height


func dead() -> void:
	$MeshInstance3D.visible = false


func process_collision() -> void:
	for i in get_slide_collision_count():
		var c := get_slide_collision(i).get_collider()
		if c is TargetStructure:
			GameManager.on_character_collide_structure(self, c as TargetStructure)


func cleanup_requests() -> void:
	jump_requests.clear()
	

#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
