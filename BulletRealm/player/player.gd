class_name Player
extends CharacterBody2D
## Player : Character controlled by the user.


const BULLET: PackedScene = preload("res://attacks/bullet.tscn")

const MOTION_SPEED: float = 450.0
const BOMB_RATE = 0.5

@export var synced_position := Vector2()

@export var stunned = false

@onready var attrs: Attributes = $Attributes
@onready var status_effects: StatusEffects = $StatusEffects

@onready var sprite = $Sprite
@onready var animation = $Animation

@onready var cursor = $Cursor
@onready var health_bar = $HealthBar
@onready var mana_bar = $ManaBar

@onready var player_status_panel = $CanvasLayer/PlayerStatusPanel

@onready var inputs = $Inputs
var last_bomb_time = BOMB_RATE
var current_anim = ""

var _active_status_effect_visual: StatusEffect.Type = StatusEffect.Type.NONE
var _visual_effect_tween: Tween

var _time_since_last_attack: float = 0.0
var _last_input_velocity: Vector2 = Vector2.ZERO


func _to_string() -> String:
	return "Player"


func _ready():
	stunned = false
	#position = synced_position
	if str(name).is_valid_int():
		get_node("Inputs/InputsSync").set_multiplayer_authority(str(name).to_int())
	
	attrs.init_level(1, 0, 50, 0)
	attrs.init_core_resources(50.0, 100.0, 30.0, 100.0)
	
	attrs.update_stat(Attributes.HP_REGEN, 2.3)
	attrs.update_stat(Attributes.MANA_REGEN, 1.7)


func _process(delta):
	_update_delta_tracking(delta)
	_move_cursor_to_mouse()
	_handle_local_input()
	_update_debug_label()
	_apply_damage_over_time_effects(delta)
	_update_status_effect_and_visuals()
	_apply_regen(delta)
	_update_resource_bars()
	player_status_panel.update(attrs, status_effects)


func _update_delta_tracking(delta) -> void:
	_time_since_last_attack += delta


func _apply_damage_over_time_effects(delta) -> void:
	var dot_effects: Array[StatusEffect] = status_effects.get_damage_over_time_effects()
	attrs.apply_damage_over_time_effects(dot_effects, delta)


func _update_status_effect_and_visuals() -> void:
	# Burning has a higher priority than healing and other effects.
	if status_effects.is_burning():
		if _active_status_effect_visual == StatusEffect.Type.BURNING:
			return
		
		_visual_effect_tween = TweenUtils.tween_flash_red(sprite, 0.3)
		_active_status_effect_visual = StatusEffect.Type.BURNING
	else:
		# Reset to default color.
		sprite.self_modulate = Color.WHITE
		TweenUtils.kill_tween(_visual_effect_tween)
		_active_status_effect_visual = StatusEffect.Type.NONE


func _apply_regen(delta) -> void:
	if attrs.current_hp() >= 0.0:
		# Only apply HP regen if this unit hasn't been reduced to zero HP.
		attrs.apply_hp_regen(delta)
	
	attrs.apply_mana_regen(delta)


func _update_resource_bars() -> void:
	health_bar.set_amount(attrs.current_hp())
	mana_bar.set_amount(attrs.current_mana())


func _physics_process(delta):
	inputs.update()
	# TODO: Figure out multiplayer sync.
	if multiplayer.multiplayer_peer == null or str(multiplayer.get_unique_id()) == str(name):
		# The client which this player represent will update the controls state, and notify it to everyone.
		inputs.update()
	
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
		# Everybody runs physics. I.e. clients tries to predict where they will be during the next frame.
		velocity = inputs.motion * MOTION_SPEED
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
	if Engine.get_physics_frames() % 4 == 0:
		# To prevent a jittery label, only update once every 4 physics frames.
		get_node("Label").text = "CurrentHP: %.1f HPRegen: %.1f \n CurrentMana: %.1f ManaRegen: %.2f \n pos: ( %.1f, %.1f )" % [
			attrs.current_hp(),
			attrs.stat(Attributes.HP_REGEN),
			attrs.current_mana(),
			attrs.stat(Attributes.MANA_REGEN),
			position.x,
			position.y
		]


func set_player_name(value):
	get_node("label").text = value


@rpc("call_local")
func exploded(_by_who):
	if stunned:
		return
	stunned = true
	animation.play("stunned")


# Note: This is currently not synchronized for multiplayer.
func _handle_local_input() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if _time_since_last_attack >= attrs.attack_delay():
			_shoot_bullet()


func _move_cursor_to_mouse() -> void:
	var my_pos: Vector2 = global_position
	var cursor_weight_range = VectorUtils.get_max_cursor_range_weight(self, attrs.cursor_range())
	
	if cursor_weight_range >= 1.0:
		cursor.global_position = get_global_mouse_position()
	else:
		cursor.global_position = my_pos.lerp(get_global_mouse_position(), cursor_weight_range)


func _shoot_bullet() -> void:
	_time_since_last_attack = 0.0
	var bullet: Bullet = BULLET.instantiate()
	# This calculates a point in "front" of the player, which is a normalized vector
	# from global coordinates (0, 0).
	var start_pos = global_position.direction_to(cursor.global_position).normalized() * 25.0
	# Move the vector to a point relative to the player's location.
	start_pos += self.global_position
	# TODO: Implement proper damage mechanics
	var damage: DamageUnit = DamageUnit.new(attrs.level(),
			attrs.raw_attack_power(), DamageUnit.Type.PHYSICAL)
	bullet.init(start_pos, cursor.global_position, 300.0, 1.2, damage)
	# Consider playing a quick sound effect.
	get_node("Projectiles").add_child(bullet)


func _on_hitbox_area_entered(area):
	AreaUtils.add_status_effect_if_necessary(area, status_effects)


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
