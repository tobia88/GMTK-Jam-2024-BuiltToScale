extends Node3D


class_name TutorialTrigger


@export_multiline var tutorial_text: String


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Character:
		GameManager.active_level.on_character_enter_tutorial_trigger(body as Character, self)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Character:
		GameManager.active_level.on_character_exit_tutorial_trigger(body as Character, self)
