class_name PlayerBullet
extends BaseBullet


enum Type { RED_BULLET }

@export var bullet_type: Type = Type.RED_BULLET

const BULLET_RED_OUTLINE = preload("res://assets/images/bullet_red_outline.png")


func _ready():
	super()
	sprite.texture = BULLET_RED_OUTLINE


func _get_fade_duration() -> float:
	return 0.3
