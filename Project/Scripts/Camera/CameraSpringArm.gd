extends SpringArm3D

const yaw_sensitivity = 0.1
const pitch_sensitivity = 0.1

@onready var camera: Camera3D = %Camera3D
@onready var target = $".."

var mouse_input_vel: Vector2 = Vector2.ZERO
var target_quat: Quaternion = Quaternion.IDENTITY
var target_offset: Vector3 = Vector3.ZERO

var parent_character: Character

var cam_offset := Vector3.ZERO
var target_cam_offset := Vector3.ZERO

var default_length = -1.0
var target_length = -1.0


func _ready() -> void:
	default_length = camera.position.z
	
	target_length = default_length
	spring_length = default_length

	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	target_offset = position
	
	parent_character = get_parent() as Character

	top_level = true


func init_pos() -> void:
	global_position = target.transform * target_offset


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_input_vel = -event.relative


func _process(delta: float) -> void:
	#_update_camera_rotation(delta)
	_update_camera_zoom(delta)
	_update_camera_position(delta)


func _update_camera_rotation(delta: float) -> void:
	var add_yaw := deg_to_rad(mouse_input_vel.x) * yaw_sensitivity
	var new_yaw := wrapf(rotation.y + add_yaw, 0.0, TAU)

	var add_pitch = deg_to_rad(mouse_input_vel.y) * pitch_sensitivity
	var new_pitch = clampf(rotation.x + add_pitch, -TAU * 0.25, 0.0 )
	var target_quat = Quaternion.from_euler(Vector3(new_pitch, new_yaw, 0.0))

	const rot_smooth_spd := 100.0
	quaternion = quaternion.slerp(target_quat, 1.0 - exp(-rot_smooth_spd * delta ))

	mouse_input_vel = Vector2.ZERO


func _exp_lerp(from: Variant, to: Variant, delta: float, decay: float = 5.0 ) -> Variant:
	return to + (to - from) * exp(-decay * delta)


func _update_camera_zoom(delta: float) -> void:
	var zoom_dict: Dictionary = {
		1: default_length,
		2: 35.0,
		3: 50.0
	}

	# zoom out if character scaled up
	target_length = zoom_dict[parent_character.scale_lvl]
	const zoom_smooth_spd := 1.0
	spring_length = lerp(spring_length, target_length, 1.0 - exp(-delta * zoom_smooth_spd))


func _update_camera_position(delta: float) -> void:
	var vel_2d = Vector3(parent_character.velocity.x, 0.0, parent_character.velocity.z)
	
	var offset_lerp := 1.0
	if not vel_2d.is_zero_approx():
		offset_lerp = 2.0
		var new_cam_offset := vel_2d.normalized() * 2.0
		cam_offset = cam_offset.move_toward(new_cam_offset, delta)
	
	var new_pos: Vector3 = target.transform * target_offset + cam_offset

	if not parent_character.is_on_floor():
		new_pos.y = global_position.y

	const smooth_spd := 10.0
	global_position.x = lerp(global_position.x, new_pos.x, 1.0 - exp(-delta * smooth_spd))
	global_position.y = lerp(global_position.y, new_pos.y, 1.0 - exp(-delta * smooth_spd * 0.5))
	global_position.z = lerp(global_position.z, new_pos.z, 1.0 - exp(-delta * smooth_spd))
