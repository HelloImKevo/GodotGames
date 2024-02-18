class_name PlayerBullet
extends BaseBullet


enum Type { RED_BULLET }


func _ready():
	super()
	_create_random_bullet()


func _get_fade_duration() -> float:
	return 0.3


## For testing purposes only.
func _create_random_bullet() -> void:
	var bullet_data: Dictionary = BulletManager.PLAYER_BULLETS
	var key: String = bullet_data.keys().pick_random()
	var sprite_data: BulletSpriteData = bullet_data[key]
	sprite.frame = sprite_data.frame
	sprite.rotation_degrees = sprite_data.rotation_degrees
	sprite.scale = Vector2(sprite_data.scale, sprite_data.scale)
	sprite.flip_h = sprite_data.flip_h
