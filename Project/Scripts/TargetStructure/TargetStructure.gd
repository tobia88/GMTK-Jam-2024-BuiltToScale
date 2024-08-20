extends StaticBody3D

class_name TargetStructure

@export var required_scale_lvl: int = 1

func _process(delta: float) -> void:
	# update label
	#$Label3D.text = "Lvl=%d" % required_scale_lvl
	pass


func dead() -> void:
	AudioManager.play_sfx($AudioStreamPlayer_Explosion.stream)
	$Node3D/GPUParticles3D.emitting = true
	$Node3D/GPUParticles3D.reparent(get_tree().current_scene)
	$Node3D/GPUParticles3D2.emitting = true
	$Node3D/GPUParticles3D2.reparent(get_tree().current_scene)
	queue_free()
