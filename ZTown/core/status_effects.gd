class_name StatusEffects
extends Node

'''
{
	"hazard_burning_ground": StatusEffect("hazard_burning_ground", Type.BURNING, 5.0)
}
'''
var _key_to_effect_dict: Dictionary = {}


# TODO: Look into adding unit tests.
func add_effect(effect: StatusEffect):
	_key_to_effect_dict[effect.key] = effect


func remove_effect(effect: StatusEffect):
	if _key_to_effect_dict.erase(effect.key):
		print("effect erased: ", effect)


func remove_effects_with_key(identifier: String):
	if _key_to_effect_dict.erase(identifier):
		print("effect erased: ", identifier)


func get_damage_over_time_effects() -> Array[StatusEffect]:
	var dot_effects: Array[StatusEffect] = []
	for e: StatusEffect in _key_to_effect_dict.values():
		if StatusEffect.Type.BURNING == e.type:
			dot_effects.append(e)
	
	return dot_effects


func is_burning() -> bool:
	for e: StatusEffect in _key_to_effect_dict.values():
		if StatusEffect.Type.BURNING == e.type:
			return true
	
	return false
