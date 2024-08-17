extends Node3D

class_name PlayerCtrl

@export var character_template: PackedScene

var active_character: Character

var parent_level: Level:
	get:
		return get_parent() as Level
		

func _ready() -> void:
	%SpringArm3D.spring_length = %Camera3D.position.z


func spawn_character() -> void:
	active_character = character_template.instantiate()
	parent_level.add_child(active_character)
