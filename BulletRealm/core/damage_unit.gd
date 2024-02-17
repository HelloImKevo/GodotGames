class_name DamageUnit


enum Type { PHYSICAL, FIRE, HOLY, HEALING }

## Level of the source of this damage or healing output.
var _owner_level: int
## Raw damage output by the source (based on owner's attack power,
## equipment, attributes and other factors).
var _raw_amount: float
## Type of damage. Physical is the most common. Healing is also considered
## a damage unit, to simplify things.
var _type: Type


func _to_string() -> String:
	return "DamageUnit (%s, %.2f, %s)" % [_owner_level, _raw_amount, _type]


func _init(owner_level: int, raw_amount: float, type: Type):
	_owner_level = owner_level
	_raw_amount = raw_amount
	_type = type


func owner_level() -> int:
	return _owner_level


func raw_amount() -> float:
	return _raw_amount


# TODO: Add damage range variance to attacks - slow, powerful attacks, vs
# quick, weak attacks. Lightning dmg 10 - 250 vs. Fire dmg 50 - 75

## Note: Damage scaling applies both ways, to players and enemies.
func scaled_amount(recipient_level: int) -> float:
	if recipient_level <= _owner_level:
		return _raw_amount
	else:
		# ex 1: r_lvl = 10, o_lvl = 2
		# raw = 500
		# 2 / 10 = 0.2 * 500 = 100
		# ex 2: (2 / 3) * 500
		var scaled: float = (float(_owner_level) / float(recipient_level)) * _raw_amount
		var damage_amount = scaled * _get_difficulty_scale_factor()
		print("DU = %s -> scaled = %.2f -> damage_amount = %.2f" % [self, scaled, damage_amount])
		return damage_amount


## This could be converted to some game constant for singleplayer mode.
## 1.2 = Easy, 1.0 = Normal, 0.5 = Hard
func _get_difficulty_scale_factor() -> float:
	return 1.2


func is_healing() -> bool:
	return _type == Type.HEALING
