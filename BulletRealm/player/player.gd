class_name Player
extends CharacterBody2D
## Player : Character controlled by the user.


const BULLET: PackedScene = preload("res://attacks/player_bullet.tscn")

const MOTION_SPEED: float = 450.0
const BOMB_RATE = 0.5

## Note: It is imperative that this property is added to the MultiplayerSynchronizer
## 'Replication' module in the Godot IDE. The Label:text should be added as well.
@export var synced_position := Vector2()

@export var stunned: bool = false
@export var show_debug_label: bool = false

@onready var attrs: Attributes = $Attributes
@onready var status_effects: StatusEffects = $StatusEffects

@onready var sprite = $Sprite
@onready var animation = $Animation
@onready var hit_sound = $HitSound

@onready var cursor = $Cursor
@onready var health_bar = $HealthBar
@onready var mana_bar = $ManaBar

@onready var player_input = $PlayerInput
@onready var player_cam: Camera2D = $PlayerCam

# TODO: This needs to be re-worked - this spawns two (or more!) GUIs for multiplayer.
# Should probably be controlled with Signals up to the Client Presentation Layer.
# Have to solve for this though:
# player_gui.get_status_panel().update(attrs, status_effects)
@onready var player_gui = $PlayerGUI

@onready var inputs = $PlayerInput
var last_bomb_time = BOMB_RATE
var current_anim = ""

var _active_status_effect_visual: StatusEffect.Type = StatusEffect.Type.NONE
var _visual_effect_tween: Tween

var _time_since_last_attack: float = 0.0
var _last_input_velocity: Vector2 = Vector2.ZERO

var logger: LogStream = LogStream.new(_to_string(), LogStream.LogLevel.DEBUG)

@export var player_name: String = "N/A"


## Returns the name of multiplayer unique ID (integer) assigned to this Node.name.
func get_player_id() -> int:
	return str(name).to_int()


func _to_string() -> String:
	return "Player '%s'" % [name]


func _ready():
	stunned = false
	position = synced_position
	
	# TODO: Figure out better multiline string concat.
	MPLog.info("""
	Player: _ready -> My player_id = %s , multiplayer.unique_id = %s , 
	my PlayerInput's multiplayer_authority = %s ; setting up my Player Camera
	""" % [get_player_id(), multiplayer.get_unique_id(), get_player_id()])

	# Set the camera as current if we are this player.
	if get_player_id() == multiplayer.get_unique_id():
		player_cam.make_current()
	
	# Specify control of this Node's input using the Node's unique ID,
	# which corresponds to the assigned multiplayer peer ID.
	player_input.set_multiplayer_authority(get_player_id())
	
	# TODO: Rework this so the player name label is separate from debug label.
	#if not show_debug_label:
		#get_node("Label").visible = false
	
	attrs.init_level(1, 0, 50, 0)
	attrs.init_core_resources(50.0, 1200.0, 30.0, 150.0)
	
	attrs.update_stat(Attributes.HP_REGEN, 2.3)
	attrs.update_stat(Attributes.MANA_REGEN, 1.7)


func _process(delta):
	_update_delta_tracking(delta)
	_move_cursor_to_mouse()
	_update_debug_label()
	_apply_damage_over_time_effects(delta)
	_update_status_effect_and_visuals()
	_apply_regen(delta)
	_update_resource_bars()
	
	player_gui.get_status_panel().update(attrs, status_effects)


func _update_delta_tracking(delta) -> void:
	_time_since_last_attack += delta


func _apply_damage_over_time_effects(delta) -> void:
	var dot_effects: Array[StatusEffect] = status_effects.get_damage_over_time_effects()
	attrs.apply_damage_over_time_effects(dot_effects, delta)


func _update_status_effect_and_visuals() -> void:
	# Burning has a higher priority than healing and other effects.
	if status_effects.is_burning():
		if _visual_effect_tween == null or not _visual_effect_tween.is_running():
			_visual_effect_tween = TweenUtils.tween_flash_red(sprite, 0.3)
		_active_status_effect_visual = StatusEffect.Type.BURNING
	else:
		_active_status_effect_visual = StatusEffect.Type.NONE


func _apply_regen(delta) -> void:
	if attrs.current_hp() >= 0.0:
		# Only apply HP regen if this unit hasn't been reduced to zero HP.
		attrs.apply_hp_regen(delta)
	
	attrs.apply_mana_regen(delta)


func _update_resource_bars() -> void:
	if EngineUtils.ui_update_interval():
		player_gui.update_with_attrs(attrs)
		health_bar.set_amount(attrs.current_hp(), attrs.max_hp())
		mana_bar.set_amount(attrs.current_mana(), attrs.max_mana())


func _physics_process(delta):
	if multiplayer.multiplayer_peer == null or is_multiplayer_authority():
		# The server updates the position that will be notified to the clients.
		synced_position = position
		# And increase the bomb cooldown spawning one if the client wants to.
		last_bomb_time += delta
		if not stunned and is_multiplayer_authority() and inputs.bombing and last_bomb_time >= BOMB_RATE:
			last_bomb_time = 0.0
			#get_node("../../BombSpawner").spawn([position, str(name).to_int()])
	else:
		# The client simply updates the position to the last known one.
		position = synced_position
	
	if not stunned:
		var y = 42
		# Everybody runs physics. I.e. clients tries to predict where they will be during the next frame.
		#velocity = inputs.motion * MOTION_SPEED
		#move_and_slide()
	
	velocity = inputs.motion * MOTION_SPEED
	
	_physics_handle_captured_client_input()
	
	move_and_slide()
	
	# Also update the animation based on the last known player input state
	var new_anim = "standing"
	
	if inputs.motion.y < 0:
		new_anim = "walk_up"
	elif inputs.motion.y > 0:
		new_anim = "walk_down"
	elif inputs.motion.x < 0:
		new_anim = "walk_left"
	elif inputs.motion.x > 0:
		new_anim = "walk_right"
	#if stunned:
		#new_anim = "stunned"
	if new_anim != current_anim:
		current_anim = new_anim
		animation.play(current_anim)


func _update_debug_label():
	# TODO: Temporary for testing purposes.
	if true:
		# TODO: Fix wrong player names being propagated on clients.
		#get_node("Label").text = "%s (%s)" % [player_name, get_player_id()]
		get_node("Label").text = "%s (%s)" % [GameManager.hub.local_client_player_name, get_player_id()]
		return
	
	if not show_debug_label:
		return
	
	if EngineUtils.ui_update_interval():
		get_node("Label").text = "CurrentHP: %.1f HPRegen: %.1f \n CurrentMana: %.1f ManaRegen: %.2f \n pos: ( %.1f, %.1f )" % [
			attrs.current_hp(),
			attrs.stat(Attributes.HP_REGEN),
			attrs.current_mana(),
			attrs.stat(Attributes.MANA_REGEN),
			position.x,
			position.y
		]


func set_player_name(p_name: String):
	player_name = p_name
	# In the MultiplayerSychronizer 'Replication' tab, this Label should 'Never' replicate.
	get_node("Label").text = p_name


func get_camera_offset() -> Vector2:
	# TODO: Implement camera offset logic.
	var is_status_panel_open = true
	if is_status_panel_open:
		return Vector2(120.0, 0.0)
	else:
		return Vector2.ZERO


@rpc("call_local")
func exploded(_by_who):
	if stunned:
		return
	stunned = true
	animation.play("stunned")


# Should be called after inputs.capture_client_input().
func _physics_handle_captured_client_input() -> void:
	if inputs.is_shooting:
		if _time_since_last_attack >= attrs.attack_delay():
			_shoot_bullet.rpc()
	
	# Reset shooting state.
	inputs.is_shooting = false


func _move_cursor_to_mouse() -> void:
	var my_pos: Vector2 = global_position
	var cursor_weight_range = VectorUtils.get_max_cursor_range_weight(self, attrs.cursor_range())
	
	if cursor_weight_range >= 1.0:
		cursor.global_position = get_global_mouse_position()
	else:
		cursor.global_position = my_pos.lerp(get_global_mouse_position(), cursor_weight_range)


@rpc("authority", "call_local")
func _shoot_bullet() -> void:
	# TODO: The bullet is being spawned on both clients, but is aiming towards the single cursor
	# on the desktop (so the bullet travels in two different directions).
	# Maybe a ProjectileSpawner needs to be used with an @rpc decorator or multiplayer.is_server()
	#logger.info("Player '%s' is now shooting!" % [name])
	_time_since_last_attack = 0.0
	var bullet: PlayerBullet = BULLET.instantiate()
	# This calculates a point in "front" of the player, which is a normalized vector
	# from global coordinates (0, 0).
	logger.info("cursor.global_position = %s" % [cursor.global_position])
	var start_pos = global_position.direction_to(cursor.global_position).normalized() * 25.0
	# Move the vector to a point relative to the player's location.
	start_pos += self.global_position
	# TODO: Implement proper damage mechanics
	var damage: DamageUnit = DamageUnit.from_attrs(attrs, DamageUnit.Type.PHYSICAL)
	bullet.init(start_pos, cursor.global_position, 300.0, 1.2, damage)
	# Consider playing a quick sound effect.
	SceneTreeHelper.add_projectile(self, bullet)


func _on_hitbox_area_entered(area):
	AreaUtils.add_status_effect_if_necessary(area, status_effects)
	
	if AreaUtils.is_enemy_bullet(area):
		var bullet: EnemyBullet = area
		_take_damage(bullet.get_damage_unit())


func _take_damage(damage_unit: DamageUnit) -> void:
	var scaled_damage: float = damage_unit.scaled_amount(attrs.level())
	attrs.take_damage(scaled_damage)
	
	if _visual_effect_tween == null or not _visual_effect_tween.is_running():
		_visual_effect_tween = TweenUtils.tween_flash_red(sprite, 0.2)
	SoundManager.player_hit_sound(hit_sound)


func _on_hitbox_area_exited(area):
	AreaUtils.remove_status_effect_if_necessary(area, status_effects)


func physics_process_old(_delta):
	get_input_old()
	move_and_slide()
	rotation = _last_input_velocity.angle()


func get_input_old() -> void:
	var new_velocity = Vector2.ZERO
	# Primarily used for joystick movement.
	new_velocity.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	new_velocity.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	velocity = new_velocity.normalized() * MOTION_SPEED
	
	if (Input.is_action_pressed("move_right") 
			or Input.get_action_strength("move_left") 
			or Input.get_action_strength("move_down") 
			or Input.get_action_strength("move_up")):
		# TODO: There's probably a more elegant way to solve this using the Sprite2D's
		# last updated rotation.
		_last_input_velocity = velocity
		# print("_last_input_velocity.angle(): ", _last_input_velocity.angle())
