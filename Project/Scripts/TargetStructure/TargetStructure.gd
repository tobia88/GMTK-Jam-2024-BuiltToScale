extends RigidBody3D

class_name TargetStructure

@export var required_scale_lvl: int = 1

func _process(delta: float) -> void:
	# update label
	$Label3D.text = "Lvl=%d" % required_scale_lvl

func dead() -> void:
	queue_free()
