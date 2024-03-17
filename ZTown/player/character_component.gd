extends Node2D

@onready var sprite = $Sprite
@onready var animation = $Animation

# Get the gravity from the project settings to be synced with RigidBody nodes.
# Default value of 980 (9.8 m/s^2).
#var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity: float = 250.0

var current_anim = "idle"
var _jump_speed: float = 0.0
var _max_jump_height: float = 0.0
var _jumping: bool = false


func get_sprite() -> Sprite2D:
	return sprite


func is_jumping_or_falling() -> bool:
	return _jumping or is_airborne()


func play(anim_name: String, motion: Vector2) -> void:
	if motion.x < 0.0:
		sprite.flip_h = true
	elif motion.x > 0.0:
		sprite.flip_h = false
	
	if anim_name != current_anim:
		print("Playing new anim , ", anim_name)
		current_anim = anim_name
		animation.play(anim_name)


func jump(speed: float, max_height: float):
	# We're allowed to jump.
	_jumping = true
	_jump_speed = speed
	_max_jump_height = max_height


func _physics_process(delta):
	if _jumping and abs(position.y) < _max_jump_height:
		# Move the body upwards.
		print("Skin -> Jumping and pos.y < jump_height , %.1f , %.1f" % [position.y, _jump_speed])
		position.y += -abs(_jump_speed) * delta
	elif abs(position.y) >= _max_jump_height:
		_jumping = false
	
	if not _jumping and is_airborne():
		print("Skin -> Falling ...")
		# We've reached max height, time to start falling.
		position.y += gravity * delta
	
	if position.y >= 0.0:
		# The body has hit the ground. We're no longer jumping.
		position.y = 0.0
		_jumping = false


func is_airborne() -> bool:
	var height: float = abs(position.y)
	return height > 0.0
