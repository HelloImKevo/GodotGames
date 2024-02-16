class_name Attributes
extends Node

# -- Integer Stats

const LEVEL: String = "Level"
const CURRENT_EXP: String = "CurrentExp"
const EXP_REQUIRED_NEXT_LEVEL: String = "ExpRequiredNextLevel"
const TOTAL_EXP: String = "TotalExp"

# -- Level Scaling Stats: Vitality (HP per level), Strength (DMG per level),
# -- Toughness (DEF per level), Intellect (Magic DMG)

const VITALITY: String = "Vitality"
const STRENGTH: String = "Strength"
const TOUGHNESS: String = "Toughness"
const INTELLECT: String = "Intellect"

# -- Core Resources: HP, Mana

const CURRENT_HP: String = "CurrentHP"
const MAX_HP: String = "MaxHP"
const CURRENT_MANA: String = "CurrentMana"
const MAX_MANA: String = "MaxMana"
const HP_REGEN: String = "HPRegen"
const MANA_REGEN: String = "ManaRegen"

var _stats: Dictionary = {
	# Integers
	LEVEL: 0,
	CURRENT_EXP: 0,
	EXP_REQUIRED_NEXT_LEVEL: 0,
	TOTAL_EXP: 0,
	
	VITALITY: 0,
	STRENGTH: 0,
	TOUGHNESS: 0,
	INTELLECT: 0,
	
	# Floats
	CURRENT_HP: 0.0,
	MAX_HP: 0.0,
	CURRENT_MANA: 0.0,
	MAX_MANA: 0.0,
	"RunSpeed": 0.0,
	HP_REGEN: 0.0,
	MANA_REGEN: 0.0,
	"CursorRange": 0.0
}


func _to_string() -> String:
	return "Attributes"


func _ready():
	pass


func init_level(starting_level: int, current_exp: int, exp_required_next_level: int, total_exp: int) -> void:
	assert(current_exp <= total_exp)
	update_stat(LEVEL, starting_level)
	update_stat(CURRENT_EXP, current_exp)
	update_stat(EXP_REQUIRED_NEXT_LEVEL, exp_required_next_level)
	update_stat(TOTAL_EXP, total_exp)


func init_core_resources(start_hp: float, max_hp: float, start_mana: float, max_mana: float) -> void:
	# Note: MAX values must be specified first.
	update_stat(MAX_HP, max_hp)
	update_stat(MAX_MANA, max_mana)
	
	update_stat(CURRENT_HP, start_hp)
	update_stat(CURRENT_MANA, start_mana)


## Returns this unit's current HP snapped to the nearest whole number. Do not use this
## to apply "over time" effects!
func current_hp() -> float:
	return snappedf(stat(CURRENT_HP), 1.0)


func take_damage(damage) -> void:
	update_stat(CURRENT_HP, -(abs(damage)))


func current_mana() -> float:
	return stat(CURRENT_MANA)


## Gets the current value for the specified stat [key].
func stat(key: String) -> Variant:
	return _stats[key]


func update_stat(key: String, amount) -> void:
	var new_amount = _stats[key] + amount
	
	# Note: I ran into what I thought was a floating point rounding bug, but it
	# the issue was that HP regen was immediately being applied after the unit was
	# reduced to zero HP.
	if CURRENT_HP == key:
		_set_stat(key, clampf(new_amount, 0.0, _stats[MAX_HP]))
	elif CURRENT_MANA == key:
		_set_stat(key, clampf(new_amount, 0.0, _stats[MAX_MANA]))
	else:
		_set_stat(key, new_amount)


## Uses the delta to calculate and take damage for multiple damage per second effects.
func apply_damage_over_time_effects(dot_effects: Array[StatusEffect], delta) -> void:
	for e: StatusEffect in dot_effects:
		var damage_tick = e.damage_per_second * delta
		take_damage(damage_tick)


## Heals HP per second based on delta since last process.
func apply_hp_regen(delta) -> void:
	var hp_regen = _stats[HP_REGEN] * delta
	update_stat(CURRENT_HP, hp_regen)


## Restores Mana per second based on delta since last process.
func apply_mana_regen(delta) -> void:
	var mana_regen = _stats[MANA_REGEN] * delta
	update_stat(CURRENT_MANA, mana_regen)


func _set_stat(key: String, amount) -> void:
	_stats[key] = amount
