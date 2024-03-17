class_name DamageUnit


enum Type { PHYSICAL, FIRE, HOLY, HEALING }

## Level of the source of this damage or healing output.
var _owner_level: int
## Raw damage output by the source (based on owner's attack power,
## equipment, attributes and other factors).
var _raw_amount_min: float
var _raw_amount_max: float
## Type of damage. Physical is the most common. Healing is also considered
## a damage unit, to simplify things.
var _type: Type


func _to_string() -> String:
	return "DamageUnit (%s, %.1f - %.1f, %s)" % [
			_owner_level, _raw_amount_min, _raw_amount_max, _type]


static func from_attrs(attrs: Attributes, type: Type) -> DamageUnit:
	return DamageUnit.new(attrs.level(),
			attrs.raw_attack_min(), attrs.raw_attack_max(), type)


func _init(o_level: int, raw_min: float, raw_max: float, type: Type):
	_owner_level = o_level
	_raw_amount_min = raw_min
	_raw_amount_max = raw_max
	_type = type


func owner_level() -> int:
	return _owner_level


# TODO: Add damage range variance to attacks - slow, powerful attacks, vs
# quick, weak attacks. Lightning dmg 10 - 250 vs. Fire dmg 50 - 75

## Note: Damage scaling applies both ways, to players and enemies.
func scaled_amount(recipient_level: int) -> float:
	var raw_damage = randf_range(_raw_amount_min, _raw_amount_max)
	
	if recipient_level <= _owner_level:
		return raw_damage
	else:
		# ex 1: r_lvl = 10, o_lvl = 2
		# raw = 500
		# 2 / 10 = 0.2 * 500 = 100
		# ex 2: (2 / 3) * 500
		var scaled: float = (float(_owner_level) / float(recipient_level)) * raw_damage
		var damage_amount = scaled * _get_difficulty_scale_factor()
		print("DU = %s -> scaled = %.2f -> damage_amount = %.2f" % [self, scaled, damage_amount])
		return damage_amount


## This could be converted to some game constant for singleplayer mode.
## 1.2 = Easy, 1.0 = Normal, 0.5 = Hard
func _get_difficulty_scale_factor() -> float:
	return 1.2


func is_healing() -> bool:
	return _type == Type.HEALING
