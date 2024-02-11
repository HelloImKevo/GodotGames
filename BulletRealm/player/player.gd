class_name Player
extends CharacterBody2D
## Player : Survivor character controlled by the user.


const SPEED: float = 450.0

var _last_input_velocity: Vector2 = Vector2.ZERO


func _to_string() -> String:
	return "Player"


func _physics_process(_delta):
	get_input()
	move_and_slide()
	rotation = _last_input_velocity.angle()


func get_input() -> void:
	var new_velocity = Vector2.ZERO
	# Primarily used for joystick movement.
	new_velocity.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	new_velocity.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	velocity = new_velocity.normalized() * SPEED
	
	if (Input.is_action_pressed("right") 
			or Input.get_action_strength("left") 
			or Input.get_action_strength("down") 
			or Input.get_action_strength("up")):
		# TODO: There's probably a more elegant way to solve this using the Sprite2D's
		# last updated rotation.
		_last_input_velocity = velocity
		# print("_last_input_velocity.angle(): ", _last_input_velocity.angle())
