class_name Enemy
extends CharacterBody2D


## What level is this enemy? Determines [Attributes] values.
@export var level: int = 10

const BULLET = preload("res://attacks/enemy_bullet.tscn")

@onready var attrs: Attributes = $Attributes

@onready var player_detect = $PlayerDetect
@onready var ray_cast = $PlayerDetect/RayCast

@onready var animation = $Animation
@onready var unit_label = $UnitLabel
@onready var health_bar = $HealthBar
@onready var floating_numbers: FloatingNumbers = $FloatingNumbers

@onready var sound = $Sound

@onready var shoot_timer = $ShootTimer

var _time_since_last_attack: float
var _default_sight_distance: float
var _dying: bool = false


func _to_string() -> String:
	return "Enemy"


func _ready():
	set_physics_process(false)
	_default_sight_distance = ray_cast.target_position.y
	
	attrs.init_level(level, 0, 0, 0)
	attrs.init_core_resources(50.0, 50.0, 40.0, 40.0)
	
	attrs.update_stat(Attributes.HP_REGEN, 1.0)
	
	unit_label.set_name_and_level("Mushroom", attrs.level())
	
	_start_attack_timer()
	
	call_deferred("_late_setup")


func _late_setup():
	await get_tree().physics_frame
	call_deferred("set_physics_process", true)


func _start_attack_timer() -> void:
	shoot_timer.wait_time = randf_range(3.6, 4.4)
	shoot_timer.start()


func _process(delta):
	if attrs.is_dead():
		start_death()
	# This is for testing purposes only and will be removed.
	position.y += 6.0 * delta
	_time_since_last_attack += delta


func _physics_process(_delta):
	_raycast_to_player()
	_update_resource_bars()


func _update_resource_bars() -> void:
	health_bar.set_amount(attrs.current_hp())


func _get_nearest_player() -> Player:
	# TODO: This currently just returns the first player in the node tree.
	return get_tree().get_first_node_in_group("player")


## Continually aim the RayCast2D at the nearest [Player].
func _raycast_to_player() -> void:
	# Note: A raycast might be more expensive than simply calculating the distance,
	# but we probably want to consider Line of Sight mechanics too.
	player_detect.look_at(_get_nearest_player().global_position)


## Reminder: Bullets are [Area2D] instances, rather than "Bodies", so we must
## use on_area_entered.
func _on_hitbox_area_entered(area):
	if AreaUtils.is_player_bullet(area):
		var bullet: PlayerBullet = area
		_take_damage(bullet.get_damage_unit())


func _take_damage(damage_unit: DamageUnit) -> void:
	var scaled_damage: float = damage_unit.scaled_amount(attrs.level())
	attrs.take_damage(scaled_damage)
	# TODO: Add support for other damage types (healing, holy, crits, etc)
	floating_numbers.create_floating_number(scaled_damage)


func start_death() -> void:
	if _dying:
		return
	
	_dying = true
	set_process(false)
	set_physics_process(false)
	sound.play()
	animation.play("death")


func _on_animation_animation_finished(anim_name):
	if anim_name == "death":
		queue_free()


func _on_shoot_timer_timeout():
	_shoot_bullet()


# TODO: Play a fast animation to telegraph incoming attack.
func _shoot_bullet() -> void:
	_time_since_last_attack = 0.0
	var bullet: EnemyBullet = BULLET.instantiate()
	var target_pos = _get_nearest_player().global_position
	# This calculates a point in "front" of the player, which is a normalized vector
	# from global coordinates (0, 0).
	var start_pos = global_position.direction_to(target_pos).normalized() * 25.0
	# Move the vector to a point relative to the player's location.
	start_pos += self.global_position
	var damage: DamageUnit = DamageUnit.from_attrs(attrs, DamageUnit.Type.PHYSICAL)
	bullet.init(start_pos, target_pos, 200.0, 0.9, damage)
	# Consider playing a quick sound effect.
	SceneTreeHelper.add_projectile(self, bullet)
	_start_attack_timer()
