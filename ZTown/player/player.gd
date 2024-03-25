class_name Player
extends CharacterBody2D
## Player : Character controlled by the user.


const BULLET: PackedScene = preload("res://attacks/player_bullet.tscn")

const MOTION_SPEED: float = 450.0

@export var stunned: bool = false
@export var show_debug_label: bool = false
## Attributes for this Player character.
## A new Attributes [Resource] must be specified in the Godot IDE.
@export var attrs: Attributes = Attributes.new()

@onready var status_effects: StatusEffects = $StatusEffects

@onready var character = $Character
@onready var hitbox = $Character/Hitbox
@onready var hit_sound = $HitSound

@onready var cursor = $Cursor
@onready var label = $Character/Label
@onready var health_bar = $Character/HealthBar
@onready var mana_bar = $Character/ManaBar

@onready var player_input = $PlayerInput
@onready var player_cam: Camera2D = $PlayerCam

@onready var inputs: PlayerInput = $PlayerInput

## Readable player number. #1 refers to the first player that joined the game.
var player_number: int = 1
var device_input_id: int = -1

## Player character is actively processing a jump action.
var _jumping: bool = false

var _active_status_effect_visual: StatusEffect.Type = StatusEffect.Type.NONE
var _visual_effect_tween: Tween

var _time_since_last_attack: float = 0.0

var logger: LogStream = LogStream.new(_to_string(), LogStream.LogLevel.DEBUG)

@export var player_name: String = "N/A"


## Returns the name of multiplayer unique ID (integer) assigned to this Node.name.
func get_player_id() -> int:
	return str(name).to_int()


func _to_string() -> String:
	return "Player '%s'" % [name]


## player_num: 0-based index. 0 refers to the only player in singleplayer mode.
## device_input_id: The [DeviceInput] ID that controls this player. -1 is Keyboard
## input, while 0 - 3 is Controller input. Note that this can change at runtime,
## like if a player were to leave or quit mid-game.
func init(__player_number: int, __device_input_id: int, __player_name: String):
	player_number = __player_number
	device_input_id = __device_input_id
	player_name = __player_name


func _ready():
	stunned = false
	
	# TODO: Figure out better multiline string concat.
	MPLog.info("""
	Player: _ready -> My player_id = %s , multiplayer.unique_id = %s , 
	my PlayerInput's multiplayer_authority = %s ; setting up my Player Camera
	""" % [get_player_id(), multiplayer.get_unique_id(), get_player_id()])
	
	inputs.set_device_input_id(device_input_id)
	
	# Set the camera as current if we are this player.
	if get_player_id() == multiplayer.get_unique_id():
		player_cam.make_current()
	
	# TODO: Rework this so the player name label is separate from debug label.
	#if not show_debug_label:
		#get_node("Label").visible = false


func _process(delta):
	_update_delta_tracking(delta)
	_process_capture_client_input()
	_move_cursor_to_mouse()
	_update_debug_label()
	_apply_damage_over_time_effects(delta)
	_update_status_effect_and_visuals()
	_apply_regen(delta)
	_update_resource_bars()
	
	if am_i_the_client_player() and EngineUtils.ui_update_interval():
		GUIManager.on_player_attributes_updated.emit(attrs)
		GUIManager.on_player_status_effects_updated.emit(status_effects)


func am_i_the_client_player():
	return get_player_id() == multiplayer.get_unique_id()


func _process_capture_client_input() -> void:
	inputs.capture_client_input()


func _update_delta_tracking(delta) -> void:
	_time_since_last_attack += delta


func _apply_damage_over_time_effects(delta) -> void:
	var dot_effects: Array[StatusEffect] = status_effects.get_damage_over_time_effects()
	attrs.apply_damage_over_time_effects(dot_effects, delta)


func _update_status_effect_and_visuals() -> void:
	# Burning has a higher priority than healing and other effects.
	if status_effects.is_burning():
		if _visual_effect_tween == null or not _visual_effect_tween.is_running():
			_visual_effect_tween = TweenUtils.tween_flash_red(character.get_sprite(), 0.3)
		_active_status_effect_visual = StatusEffect.Type.BURNING
	else:
		_active_status_effect_visual = StatusEffect.Type.NONE


func _apply_regen(delta) -> void:
	if attrs.current_hp >= 0.0:
		# Only apply HP regen if this unit hasn't been reduced to zero HP.
		attrs.apply_hp_regen(delta)
	
	attrs.apply_mana_regen(delta)


func _update_resource_bars() -> void:
	if EngineUtils.ui_update_interval():
		health_bar.set_amount(attrs.current_hp_snapped(), attrs.max_hp)
		mana_bar.set_amount(attrs.current_mana, attrs.max_mana)


func is_authority():
	return multiplayer.multiplayer_peer == null or is_multiplayer_authority()


func _physics_process(_delta):
	velocity = inputs.motion * MOTION_SPEED
	
	_handle_area_collisions()
	_physics_handle_captured_client_input()
	
	# Also update the animation based on the last known player input state
	var new_anim = "idle"
	
	if character.is_jumping_or_falling():
		new_anim = "jump"
	elif inputs.motion.x != 0 or inputs.motion.y != 0:
		new_anim = "run"
	
	if _jumping:
		character.jump(250.0, 45.0)
		_jumping = false
	
	move_and_slide()
	
	character.play(new_anim, inputs.motion)


func _handle_area_collisions() -> void:
	var standing_in_fire = false
	
	if hitbox.has_overlapping_areas():
		for area in hitbox.get_overlapping_areas():
			standing_in_fire = true
			AreaUtils.add_status_effect_if_necessary(area, status_effects)
	
	if not standing_in_fire:
		AreaUtils.remove_burning_effects(status_effects)


func _update_debug_label():
	# TODO: Temporary for testing purposes.
	if true:
		# TODO: Fix wrong player names being propagated on clients.
		label.text = "%s (%s)" % [player_name, get_player_id()]
		return
	
	if not show_debug_label:
		return
	
	if EngineUtils.ui_update_interval():
		label.text = "CurrentHP: %.1f HPRegen: %.1f \n CurrentMana: %.1f ManaRegen: %.2f \n pos: ( %.1f, %.1f )" % [
			attrs.current_hp_snapped(),
			attrs.hp_regen,
			attrs.current_mana,
			attrs.mana_regen,
			position.x,
			position.y
		]


func set_player_name(p_name: String):
	player_name = p_name
	# In the MultiplayerSychronizer 'Replication' tab, this Label should 'Never' replicate.
	# label.text = p_name


func get_player_input() -> PlayerInput:
	return inputs


func get_camera_offset() -> Vector2:
	# TODO: Implement camera offset logic.
	var is_status_panel_open = true
	if is_status_panel_open:
		return Vector2(120.0, 0.0)
	else:
		return Vector2.ZERO


# Should be called after inputs.capture_client_input().
func _physics_handle_captured_client_input() -> void:
	if inputs.is_shooting:
		if _time_since_last_attack >= attrs.attack_delay:
			_shoot_bullet()
	
	# Reset shooting state.
	inputs.is_shooting = false
	
	if inputs.jumped:
		_jumping = true
		inputs.jumped = false


func _move_cursor_to_mouse() -> void:
	var my_pos: Vector2 = global_position
	var cursor_weight_range = VectorUtils.get_max_cursor_range_weight(self, attrs.cursor_range)
	
	if cursor_weight_range >= 1.0:
		cursor.global_position = get_global_mouse_position()
	else:
		cursor.global_position = my_pos.lerp(get_global_mouse_position(), cursor_weight_range)


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
	if AreaUtils.is_enemy_bullet(area):
		var bullet: EnemyBullet = area
		_take_damage(bullet.get_damage_unit())


func _take_damage(damage_unit: DamageUnit) -> void:
	if not is_authority():
		return
	
	#log_authority("take_damage")
	
	var scaled_damage: float = damage_unit.scaled_amount(attrs.level)
	print("Player -> take_damage -> scaled damage = %.1f" % [scaled_damage])
	attrs.take_damage(scaled_damage)
	
	if _visual_effect_tween == null or not _visual_effect_tween.is_running():
		_visual_effect_tween = TweenUtils.tween_flash_red(character.get_sprite(), 0.2)
	SoundManager.player_hit_sound(hit_sound)


func _on_hitbox_area_exited(_area):
	pass


#region Diagnostic Logging

func log_not_authority(func_name: String) -> void:
	MPLog.info("""
	Player: %s -> my player_id = %s , player_name = %s --> I am NOT the multiplayer authority. 
	multiplayer.unique_id = %s , my PlayerInput's multiplayer_authority = %s
	""" % [func_name, get_player_id(), player_name, multiplayer.get_unique_id(), get_player_id()])


func log_authority(func_name: String) -> void:
	MPLog.info("""
	Player: %s -> my player_id = %s , player_name = %s --> I am the multiplayer AUTHORITY. 
	multiplayer.unique_id = %s , my PlayerInput's multiplayer_authority = %s
	""" % [func_name, get_player_id(), player_name, multiplayer.get_unique_id(), get_player_id()])

#endregion
