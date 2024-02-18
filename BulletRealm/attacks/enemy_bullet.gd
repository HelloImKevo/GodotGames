class_name EnemyBullet
extends BaseBullet


func _ready():
	super()
	sprite.frame = randi_range(0, 5)


func _get_fade_duration() -> float:
	return 0.1
