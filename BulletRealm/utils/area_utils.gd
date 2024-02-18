class_name AreaUtils


static func is_enemy(area: Node) -> bool:
	return area.is_in_group(Identifier.GROUP_ENEMY)


static func is_player(area: Node) -> bool:
	return area.is_in_group(Identifier.GROUP_PLAYER)


static func is_player_bullet(area: Node) -> bool:
	return area.is_in_group(Identifier.GROUP_PLAYER_BULLET)


static func is_enemy_bullet(area: Node) -> bool:
	return area.is_in_group(Identifier.GROUP_ENEMY_BULLET)


static func is_hazard(area: Node) -> bool:
	return area.is_in_group(Identifier.GROUP_HAZARD)


static func get_hazard_effect_or_null(area) -> StatusEffect:
	if AreaUtils.is_hazard(area):
		# TODO: Introduce type safety with typeof() checks.
		var hazard: Hazard = area
		return hazard.get_area_entered_status_effect()
	
	return null


static func add_status_effect_if_necessary(area, status_effects: StatusEffects) -> void:
	var effect = get_hazard_effect_or_null(area)
	if effect != null:
		print("burning ...")
		status_effects.add_effect(effect)


static func remove_status_effect_if_necessary(area, status_effects: StatusEffects) -> void:
	var effect = get_hazard_effect_or_null(area)
	if effect != null:
		print("no longer burning!")
		status_effects.remove_effect(effect)
