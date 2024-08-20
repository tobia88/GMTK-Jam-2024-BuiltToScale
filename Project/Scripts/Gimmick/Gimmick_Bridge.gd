extends Gimmick

class_name Gimmick_Bridge

@onready var mesh_pivot: Node3D = $Mesh_Pivot
@onready var animation_tree: AnimationTree = $AnimationTree


func _process(delta: float) -> void:
	animation_tree["parameters/StateMachine/conditions/is_activated"] = is_operated
	animation_tree["parameters/StateMachine/conditions/is_idle"] = !is_operated
