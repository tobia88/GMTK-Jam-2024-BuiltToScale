extends StaticBody3D

class_name TargetStructure

@export var required_scale_lvl: int = 1

func _process(delta: float) -> void:
	# update label
	#$Label3D.text = "Lvl=%d" % required_scale_lvl
	pass


func dead() -> void:
	AudioManager.play_sfx($AudioStreamPlayer_Explosion.stream)
	queue_free()
