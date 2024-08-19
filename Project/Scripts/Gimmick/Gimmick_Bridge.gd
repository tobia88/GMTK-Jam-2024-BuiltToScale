extends Gimmick

class_name Gimmick_Bridge

@onready var mesh_pivot: Node3D = $Mesh_Pivot


func _physics_process(delta: float) -> void:
	var target_pitch = 90.0 if is_operated else 0.0
	mesh_pivot.rotation_degrees = Vector3(target_pitch, 0.0, 0.0)
