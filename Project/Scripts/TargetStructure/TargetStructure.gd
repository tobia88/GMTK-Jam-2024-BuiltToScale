extends RigidBody3D

class_name TargetStructure

@export var required_scale_lvl: int = 1

func _process(delta: float) -> void:
	# update label
	$Label3D.text = "Lvl=%d" % required_scale_lvl

func _on_body_entered(body: Node) -> void:
	if body is not Character:
		return

	GameManager.on_character_collide_structure(body as Character, self)


func dead() -> void:
	queue_free()
