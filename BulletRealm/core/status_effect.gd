class_name StatusEffect
extends Node


enum Type { BURNING }

@export var key: String = Identifier.HAZARD_BURNING_GROUND
@export var type: Type = Type.BURNING
## How much damage per second this effect deals to the parent Node. This may need
## to utilize Level scaling in the future.
@export var damage_per_second: float = 0.0


func _to_string() -> String:
	return "StatusEffect (%s, %s, %.2f)" % [key, type, damage_per_second]


func _init(k: String = Identifier.HAZARD_BURNING_GROUND, t: Type = Type.BURNING, dps: float = 0.0):
	key = k
	type = t
	damage_per_second = dps
