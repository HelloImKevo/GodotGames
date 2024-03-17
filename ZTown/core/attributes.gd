class_name Attributes
extends Resource

# -- Integer Stats

@export var level: int = 1
@export var current_exp: int = 0
@export var exp_required_next_level: int = 0
@export var total_exp: int = 0

# -- Level Scaling Stats: Vitality (HP per level), Strength (DMG per level),
# -- Toughness (DEF per level), Intellect (Magic DMG)

@export var vitality: int = 1
@export var strength: int = 1
@export var toughness: int = 1
@export var intellect: int = 1

# -- Core Resources: HP, Mana

@export var current_hp: float = 20.0
@export var max_hp: float = 20.0
@export var current_mana: float = 10.0
@export var max_mana: float = 10.0
@export var hp_regen: float = 0.0
@export var mana_regen: float = 0.0
@export var raw_attack_min: float = 1.0
@export var raw_attack_max: float = 2.0

# -- Utility Stats

## Run speed as a percentage. 1.0 = 100%, and 2.0 = 200% run speed.
@export var run_speed_multiplier: float = 2.0
## Player attribute only. Determines the max cursor range for ranged attacks.
@export var cursor_range: float = 150.0
## Minimum time between standard attacks. 0.25 is a very fast attack speed!
@export var attack_delay: float = 0.25
## How fast standard projectiles travel.
@export var projectile_speed: float = 400.0


func to_dictionary() -> Dictionary:
	return {
		"level": level,
		"current_exp": current_exp,
		"exp_required_next_level": exp_required_next_level,
		"total_exp": total_exp,
		
		"vitality": vitality,
		"strength": strength,
		"toughness": toughness,
		"intellect": intellect,
		
		# Floats
		"current_hp": current_hp,
		"max_hp": max_hp,
		"current_mana": current_mana,
		"max_mana": max_mana,
		"hp_regen": hp_regen,
		"mana_regen": mana_regen,
		"raw_attack_min": raw_attack_min,
		"raw_attack_max": raw_attack_max,
		
		# Utility Stats
		"run_speed_multiplier": run_speed_multiplier,
		"cursor_range": cursor_range,
		"attack_delay": attack_delay,
		"projectile_speed": projectile_speed
	}


func _to_string() -> String:
	return "Attributes"


func init_level(
		__starting_level: int,
		__current_exp: int = 0,
		__exp_required_next_level: int = 0,
		__total_exp: int = 0) -> void:
	assert(__current_exp <= total_exp)
	level = __starting_level
	current_exp = __current_exp
	exp_required_next_level = __exp_required_next_level
	total_exp = __total_exp


func init_core_resources(start_hp: float, maximum_hp: float, start_mana: float, maximum_mana: float) -> void:
	# Note: MAX values must be specified first.
	max_hp = maximum_hp
	max_mana = maximum_mana
	
	update_current_hp(start_hp)
	update_current_mana(start_mana)


func update_current_hp(by_amount: float) -> void:
	var new_amount = current_hp + by_amount
	current_hp = clampf(new_amount, 0.0, max_hp)


func update_current_mana(by_amount: float) -> void:
	var new_amount = current_mana + by_amount
	current_mana = clampf(new_amount, 0.0, max_mana)


## Returns this unit's current HP snapped to the nearest whole number. Do not use this
## to apply "over time" effects!
func current_hp_snapped() -> float:
	return snappedf(current_hp, 1.0)


func max_hp_snapped() -> float:
	return snappedf(max_hp, 1.0)


func take_damage(damage) -> void:
	update_current_hp(-abs(damage))


func is_dead() -> bool:
	return current_hp <= 0.0


func set_attack_power(min_ap: float, max_ap: float) -> void:
	assert(min_ap <= max_ap)
	raw_attack_min = min_ap
	raw_attack_max = max_ap


## Uses the delta to calculate and take damage for multiple damage per second effects.
func apply_damage_over_time_effects(dot_effects: Array[StatusEffect], delta) -> void:
	for e: StatusEffect in dot_effects:
		var damage_tick = e.damage_per_second * delta
		take_damage(damage_tick)


## Heals HP per second based on delta since last process.
func apply_hp_regen(delta) -> void:
	var hp_regen_amount = hp_regen * delta
	update_current_hp(hp_regen_amount)


## Restores Mana per second based on delta since last process.
func apply_mana_regen(delta) -> void:
	var mana_regen_amount = mana_regen * delta
	update_current_mana(mana_regen_amount)
