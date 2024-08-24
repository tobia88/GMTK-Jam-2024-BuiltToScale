extends Control

class_name GameUI

@onready var control_level_cleared : Control = %Control_LevelCleared
@onready var control_planning: Control = %Control_Planning
@onready var control_tutorial: UI_Tutorial = $Control_Tutorial

func _ready() -> void:
	control_planning.visible = false
	control_level_cleared.visible = false
	control_tutorial.visible = false
