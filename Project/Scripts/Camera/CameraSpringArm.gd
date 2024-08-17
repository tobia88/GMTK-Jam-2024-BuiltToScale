extends SpringArm3D

const yaw_sensitivity = 0.1
const pitch_sensitivity = 0.1

@onready var camera: Camera3D = %Camera3D
@onready var target = $".."

var mouse_input_vel: Vector2 = Vector2.ZERO
var target_quat: Quaternion = Quaternion.IDENTITY
var target_offset: Vector3 = Vector3.ZERO


func _ready() -> void:
	spring_length = camera.position.z
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	target_offset = position

	top_level = true


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_input_vel = -event.relative


func _process(delta: float) -> void:
	_update_camera_rotation(delta)
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


func _exp_lerp(from: Variant, to: Variant, delta: float, decay: float = 5.0 ) -> float:
	return to + (to - from) * exp(-decay * delta)


func _update_camera_position(delta: float) -> void:
	global_position = target.transform * target_offset
