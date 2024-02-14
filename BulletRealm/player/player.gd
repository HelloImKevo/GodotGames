class_name Player
extends CharacterBody2D
## Player : Character controlled by the user.


const MOTION_SPEED: float = 450.0
const BOMB_RATE = 0.5

@export var synced_position := Vector2()

@export var stunned = false

@onready var attrs = $Attributes
@onready var animation = $Animation
@onready var health_bar = $HealthBar
@onready var mana_bar = $ManaBar
@onready var inputs = $Inputs
var last_bomb_time = BOMB_RATE
var current_anim = ""

var _last_input_velocity: Vector2 = Vector2.ZERO


func _to_string() -> String:
	return "Player"


func _ready():
	stunned = false
	position = synced_position
	if str(name).is_valid_int():
		get_node("Inputs/InputsSync").set_multiplayer_authority(str(name).to_int())
	
	attrs.init_level(1, 0, 50, 0)
	attrs.init_core_resources(50.0, 100.0, 30.0, 100.0)
	
	attrs.update_stat(Attributes.HP_REGEN, 2.3)
	attrs.update_stat(Attributes.MANA_REGEN, 1.7)


func _process(delta):
	_update_debug_label()
	attrs.apply_hp_regen(delta)
	attrs.apply_mana_regen(delta)
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
		get_node("Label").text = "CurrentHP: %.2f HPRegen: %.1f \n CurrentMana: %.2f ManaRegen: %.2f \n pos: ( %.1f, %.1f )" % [
			attrs.stat(Attributes.CURRENT_HP),
			attrs.stat(Attributes.HP_REGEN),
			attrs.stat(Attributes.CURRENT_MANA),
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
