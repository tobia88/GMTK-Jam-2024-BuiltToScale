extends Control

class_name UI_Tutorial

@onready var main_label: Label = $Label

var text: String:
	get: 
		return main_label.text
	set(value): 
		main_label.text = value
