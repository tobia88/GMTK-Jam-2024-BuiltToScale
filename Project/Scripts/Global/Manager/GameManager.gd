extends Node

enum LevelStates {
	NONE,
	GAME_START,
	PLAYING,
	GAME_OVER,
	ENDED
}

func on_character_enter_building(character: Character, building: Building) -> void:
	print_debug("%s is entering %s" % [character.name, building.name])
	building.is_activated = true
	
	character.scale_lvl += 1
	character.launch_by_target_height(5.0)
	
func on_character_collide_structure(character: Character, structure: TargetStructure) -> void:
	if character.scale_lvl < structure.required_scale_lvl:
		character.dead()
	else:
		structure.dead()	
	print_debug("%s is collide with %s" % [character.name, structure.name])
