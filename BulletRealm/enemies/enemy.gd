class_name Enemy
extends CharacterBody2D


## What level is this enemy? Determines [Attributes] values.
@export var level: int = 10
@export var unit_name: String = "Mushroom"
@export var min_attack: float = 10.0
@export var max_attack: float = 12.0
@export var movement_speed: float = 50.0
@export var sight_distance: float = 250.0

const BULLET = preload("res://attacks/enemy_bullet.tscn")
## The closest this enemy will get to a player before disabling navigation.
const CLOSEST_DISTANCE: float = 60.0

#region -- On Ready Node Vars --

@onready var attrs: Attributes = $Attributes

@onready var player_detect = $PlayerDetect
@onready var ray_cast = $PlayerDetect/RayCast
@onready var nav_agent: NavigationAgent2D = $NavAgent

@onready var animation = $Animation
@onready var unit_label = $UnitLabel
@onready var health_bar = $HealthBar
@onready var debug_label: Label = $DebugLabel
@onready var floating_numbers: FloatingNumbers = $FloatingNumbers

@onready var sound = $Sound

@onready var shoot_timer = $ShootTimer

#endregion -- On Ready Node Vars --

var _time_since_last_attack: float
var _time_player_has_been_in_sight: float
var _time_since_player_was_last_seen: float
var _default_sight_distance: float
var _dying: bool = false
var _can_attack: bool = true


func _to_string() -> String:
	return "Enemy: %s" % unit_name


func _ready():
	set_physics_process(false)
	
	# Set raycast sight distance.
	ray_cast.target_position.y = sight_distance
	attrs.init_level(level, 0, 0, 0)
	attrs.init_core_resources(50.0, 50.0, 40.0, 40.0)
	
	attrs.set_attack_power(min_attack, max_attack)
	attrs.update_stat(Attributes.HP_REGEN, 1.0)
	
	unit_label.set_name_and_level(unit_name, attrs.level())
	
	_start_attack_timer()
	
	call_deferred("_late_setup")


func _late_setup():
	await get_tree().physics_frame
	call_deferred("set_physics_process", true)


func _start_attack_timer() -> void:
	shoot_timer.wait_time = randf_range(3.6, 4.4)
	shoot_timer.start()


func _physics_process(delta):
	if attrs.is_dead():
		start_death()
		return
	
	_update_delta_refs(delta)
	_raycast_to_player()
	_determine_movement_destination(delta)
	_move_towards_destination(delta)
	_update_resource_bars()
	_update_debug_label()
	_attack_if_possible()


func _update_resource_bars() -> void:
	health_bar.set_amount(attrs.current_hp())


func _update_debug_label() -> void:
	debug_label.text = "Velocity: %s\nTime in Sight: %.1f\nTime since Attack: %.1f" % [
			velocity, _time_player_has_been_in_sight, _time_since_last_attack]


func _get_nearest_player() -> Player:
	# TODO: This currently just returns the first player in the node tree.
	return get_tree().get_first_node_in_group("player")


## Continually aim the RayCast2D at the nearest [Player].
func _raycast_to_player() -> void:
	# Note: A raycast might be more expensive than simply calculating the distance,
	# but we probably want to consider Line of Sight mechanics too.
	player_detect.look_at(_get_nearest_player().global_position)


func _update_delta_refs(delta) -> void:
	_time_since_last_attack += delta
	# TODO: Check to make sure it is colliding with a **player**, rather than obstacle.
	if ray_cast.is_colliding():
		_time_player_has_been_in_sight += delta
		_time_since_player_was_last_seen = 0.0
	else:
		_time_since_player_was_last_seen += delta
		_time_player_has_been_in_sight = 0.0


func _determine_movement_destination(delta) -> void:
	if ray_cast.is_colliding():
		var player: Player = _get_nearest_player()
		
		## TODO: Need state management - resetting target_position too
		## often is bad for performance and causes sticky actors
		if global_position.distance_to(player.global_position) <= CLOSEST_DISTANCE:
			# TODO: Make the enemy back off in the reverse direction a little bit,
			# to prevent enemies from getting "stuck" to a player during physics processing.
			# Immediately consider target reached, so this enemy stops moving.
			nav_agent.target_position = self.global_position
		else:
			# TODO: Need state management - resetting target_position too
			# often is bad for performance and causes sticky actors
			if nav_agent.navigation_finished:
				nav_agent.target_position = player.global_position
	else:
		# TODO: Make the unit continue moving towards the player?
		# TODO: Make the unit "wander" aimlessly, using waypoints?.
		pass


func _move_towards_destination(delta) -> void:
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		var new_velocity: Vector2
		var next_path_position: Vector2 = nav_agent.get_next_path_position()
		
		if ray_cast.is_colliding():
			# Chase the player.
			new_velocity = global_position.direction_to(next_path_position) * movement_speed
			velocity = new_velocity
		else:
			# Slow down the chase a little bit.
			new_velocity = global_position.direction_to(next_path_position) * (movement_speed * 0.8)
			
			if _time_since_player_was_last_seen > 2.0:
				# Start rapid deceleration.
				new_velocity = velocity.lerp(velocity * 0.95, 0.95)
				# If we've slowed down to a very small number, come to a full stop.
				if abs(new_velocity) < Vector2(5, 5):
					new_velocity = Vector2.ZERO
		
		velocity = new_velocity
	
	move_and_slide()


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


func _attack_if_possible() -> void:
	if not _can_attack:
		return
	
	if ray_cast.is_colliding() and _time_player_has_been_in_sight > 0.5:
		_shoot_bullet()


func _on_shoot_timer_timeout():
	_can_attack = true


# TODO: Play a fast animation to telegraph incoming attack.
func _shoot_bullet() -> void:
	_can_attack = false
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
