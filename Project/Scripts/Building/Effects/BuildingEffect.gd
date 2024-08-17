extends Resource

class_name BuildingEffect

@export var apply_scale_ratio: Vector2 = Vector2(1.5, 1.5)

func apply(character: Character)->bool:
	character.apply_scale(apply_scale_ratio)
	return true
