class_name Enemy
extends CharacterBody2D


## What level is this enemy? Determines [Attributes] values.
@export var level: int = 10

@onready var attrs: Attributes = $Attributes

@onready var player_detect = $PlayerDetect
@onready var ray_cast = $PlayerDetect/RayCast

@onready var health_bar = $HealthBar
@onready var floating_numbers: FloatingNumbers = $FloatingNumbers

var _default_sight_distance: float


func _to_string() -> String:
	return "Enemy"


func _ready():
	set_physics_process(false)
	_default_sight_distance = ray_cast.target_position.y
	
	attrs.init_level(level, 0, 0, 0)
	attrs.init_core_resources(50.0, 50.0, 40.0, 40.0)
	
	attrs.update_stat(Attributes.HP_REGEN, 1.0)
	
	call_deferred("_late_setup")


func _late_setup():
	await get_tree().physics_frame
	call_deferred("set_physics_process", true)


func _process(delta):
	position.y += 6.0 * delta


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
		var bullet: Bullet = area
		_take_damage(bullet.get_damage_unit())


func _take_damage(damage_unit: DamageUnit) -> void:
	var scaled_damage: float = damage_unit.scaled_amount(attrs.level())
	attrs.take_damage(scaled_damage)
	# TODO: Add support for other damage types (healing, holy, crits, etc)
	floating_numbers.create_floating_number(scaled_damage)
