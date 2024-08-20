extends Gimmick

class_name Gimmick_Hole

@export var effect_arr: Array

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var emission_mesh: MeshInstance3D = $Mesh_Gimmick_Windhole/Armature/Skeleton3D/Cylinder

var default_trigger_col: Color
var is_active: float = 0.0


func _ready():
	#default_trigger_col = $MeshInstance3D/MeshInstance3D2.get_active_material(0)["shader_parameter/MainColor"]
	pass
	

func _process(delta: float) -> void:
	#var material: Material = $MeshInstance3D/MeshInstance3D2.get_active_material(0)
	#material["shader_parameter/MainColor"] = Color.BLACK if is_operated else default_trigger_col
	$Area3D.monitoring = not is_operated
	is_active = move_toward(is_active, !is_operated, delta * 10.0)
	_update_animations()
	_update_materials()


func _update_animations() -> void:
	animation_tree["parameters/StateMachine/conditions/is_blowing"] = is_operated
	

func _update_materials() -> void:
	var mat : ShaderMaterial = emission_mesh.get_surface_override_material(1)
	mat.set_shader_parameter("is_active", is_active)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is not Character:
		return
		
	GameManager.active_level.on_character_enter_hole(body as Character, self)
