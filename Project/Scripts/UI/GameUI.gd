extends Control

class_name GameUI

@onready var control_level_cleared : Control = %Control_LevelCleared
@onready var control_planning: Control = %Control_Planning

func _ready() -> void:
	control_planning.visible = false
	control_level_cleared.visible = false
