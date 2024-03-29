class_name BaseBullet
extends Area2D


## This might be too costly for performance.
const BOOM: PackedScene = preload("res://graphics/explosion.tscn")

@onready var sprite: Sprite2D = $Sprite

## How long until this projectile fades away and is destroyed. Should generally
## be less than 4 seconds.
@onready var lifespan_timer: Timer = $LifespanTimer

## Normalized Vector between -1.0 and 1.0
var _dir_of_travel: Vector2 = Vector2.ZERO
## The initial target this projectile is aimed at. The projectile
## will continue traveling through the target position.
var _target_position: Vector2 = Vector2.ZERO
## How fast this projectile moves, in pixels per second.
var _speed: float
## How long this projectile stays alive, in seconds.
var _lifespan: float
## How much and what kind of damage this projectile deals. Consider multiplayer sync.
var _damage_unit: DamageUnit
## Quick fade animation that is played when the projectile's lifespan is finished.
var _fade_away: Tween


func init(start_pos: Vector2,
		target: Vector2,
		speed: float,
		lifespan: float,
		damage_unit: DamageUnit):
	_target_position = target
	_dir_of_travel = start_pos.direction_to(target)
	_speed = speed
	_lifespan = lifespan
	_damage_unit = damage_unit
	global_position = start_pos


#region -- Abstract Functions

## How quickly the projectile fades away and dies.
func _get_fade_duration() -> float:
	return 0.0

#endregion -- Abstract Functions


func _ready():
	look_at(_target_position)
	lifespan_timer.wait_time = _lifespan
	lifespan_timer.start()


func _process(delta):
	position += _dir_of_travel * _speed * delta


func get_damage_unit() -> DamageUnit:
	return _damage_unit


func create_boom() -> void:
	var boom = BOOM.instantiate()
	boom.global_position = global_position
	get_tree().root.add_child(boom)
	queue_free()


func _on_lifespan_timer_timeout():
	_fade_away = TweenUtils.tween_fade_away(sprite, _get_fade_duration())
	_fade_away.connect("finished", _on_fade_away_finished)


func _on_fade_away_finished() -> void:
	set_process(false)
	queue_free()


## Reminder: Bullets are [Area2D] right now, but they typically interact with
## physics "Bodies". So bullets should use on_area_entered and objects that can
## be hit by bullets should use on_area_entered.
func _on_body_entered(body):
	# TODO: Check which TileMap layer the bullet has collided with.
	if AreaUtils.is_enemy(body) or body is TileMap:
		_collide_and_die()


func _on_area_entered(area):
	if AreaUtils.is_player_hitbox(area):
		_collide_and_die()


func _collide_and_die():
	if lifespan_timer != null:
		lifespan_timer.stop()
	create_boom()
