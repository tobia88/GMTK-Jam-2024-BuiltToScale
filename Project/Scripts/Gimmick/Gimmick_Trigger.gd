extends Gimmick

class_name Gimmick_Trigger

@export_range(1, 3) var required_lvl: int = 1
@export var target_gimmick: Gimmick

@onready var trigger_area: Area3D = $Area3D
@onready var animation_tree: AnimationTree = $AnimationTree


func _process(delta: float) -> void:
	trigger_area.monitoring = !is_operated
	if target_gimmick:
		target_gimmick.is_operated = is_operated

	_update_animation()
	
	
func _update_animation() -> void:
	animation_tree["parameters/StateMachine/conditions/is_idle"] = !is_operated
	animation_tree["parameters/StateMachine/conditions/is_operated"] = is_operated

func on_operate_failed() -> void:
	animation_tree["parameters/OS_Failed/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Character:
		var parent_level = GameManager.active_level
		parent_level.on_character_interact_gimmick(body as Character, self)
