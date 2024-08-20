extends Gimmick

class_name Gimmick_Hole

@export var effect_arr: Array

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var emission_mesh: MeshInstance3D = $Mesh_Gimmick_Windhole/Armature/Skeleton3D/Cylinder
@onready var animation_player: AnimationPlayer = $VFX_Windhole_Blow/AnimationPlayer

var is_active := 0.0
var last_is_operated := false

func _ready():
	last_is_operated = is_operated
	

func _process(delta: float) -> void:
	$Area3D.monitoring = not is_operated
	is_active = move_toward(is_active, !is_operated, delta * 10.0)
	_update_animations()
	_update_materials()
	_update_particles()

	last_is_operated = is_operated

func _update_animations() -> void:
	animation_tree["parameters/StateMachine/conditions/is_blowing"] = is_operated
	

func _update_materials() -> void:
	var mat : ShaderMaterial = emission_mesh.get_surface_override_material(1)
	mat.set_shader_parameter("is_active", is_active)


func _update_particles() -> void:
	if last_is_operated != is_operated and is_operated:
		animation_player.active = true
		animation_player.play("Activate")
		$AudioStreamPlayer_BlowUp.play()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is not Character:
		return
		
	GameManager.active_level.on_character_enter_hole(body as Character, self)
