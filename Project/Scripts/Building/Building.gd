@tool

extends Node3D

class_name Building

@export var effect_arr: Array

var default_trigger_col: Color
var is_activated: bool

func _ready():
	default_trigger_col = $MeshInstance3D/MeshInstance3D2.get_active_material(0)["shader_parameter/MainColor"]
	
	is_activated = false
	
func _process(delta: float) -> void:
	var material: Material = $MeshInstance3D/MeshInstance3D2.get_active_material(0)
	material["shader_parameter/MainColor"] = Color.BLACK if is_activated else default_trigger_col
	$Area3D.monitoring = not is_activated
		
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is not Character:
		return
		
	GameManager.active_level.on_character_enter_building(body as Character, self)
