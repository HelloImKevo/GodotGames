extends CharacterBody2D

## Player character script for handling isometric movement and animation.
## Supports diagonal movement and plays appropriate animations based on input.
## Uses acceleration and friction for smooth movement transitions.

@export var move_speed: float = 150.0  ## Maximum movement speed in pixels per second.
@export var acceleration: float = 800.0  ## How quickly the player reaches full speed.
@export var friction: float = 1000.0  ## How quickly the player slows down when no input is given.

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D  ## Reference to the AnimatedSprite2D node.

var input_vector: Vector2 = Vector2.ZERO  ## Stores the current input direction.
var last_direction: String = "sw"  ## Keeps track of the last movement direction for idle animations.


# TODO: The character is moving directly in diagonal compass coordinates, but our
# isometric tiles are vertically squished, so we should be running at like 30 deg,
# instead of 45 deg.
func _ready():
	pass


## Processes player input and updates movement direction.
func _process_input():
	input_vector = Vector2.ZERO  # Reset input each frame.

	# Check movement inputs and update input_vector accordingly.
	if Input.is_action_pressed("move_up"):    # Move NW (-1, -1)
		input_vector += Vector2(-1, -1)
	if Input.is_action_pressed("move_down"):  # Move SE (1, 1)
		input_vector += Vector2(1, 1)
	if Input.is_action_pressed("move_left"):  # Move SW (-1, 1)
		input_vector += Vector2(-1, 1)
	if Input.is_action_pressed("move_right"): # Move NE (1, -1)
		input_vector += Vector2(1, -1)

	# Normalize the vector to maintain consistent speed in diagonals.
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		_update_animation(true)  # Play running animation.
	else:
		_update_animation(false) # Play idle animation.


## Updates the player's animation based on movement direction.
## @param running: Whether the player is moving or idle.
func _update_animation(running: bool):
	if running:
		# Determine movement direction based on input_vector.
		if input_vector.x > 0 and input_vector.y < 0:
			last_direction = "ne"
		elif input_vector.x < 0 and input_vector.y < 0:
			last_direction = "nw"
		elif input_vector.x > 0 and input_vector.y > 0:
			last_direction = "se"
		elif input_vector.x < 0 and input_vector.y > 0:
			last_direction = "sw"

		# Play the appropriate running animation.
		anim.play("run_" + last_direction)
	else:
		# Play the idle animation corresponding to the last movement direction.
		anim.play("idle_" + last_direction)


## Handles physics updates, including movement acceleration and deceleration.
## @param delta: The frame time step (in seconds).
func _physics_process(delta: float):
	_process_input()  # Process movement input.

	# Apply acceleration towards movement direction if input is given.
	if input_vector != Vector2.ZERO:
		velocity = velocity.lerp(input_vector * move_speed, acceleration * delta / move_speed)
	else:
		# Apply friction to gradually stop movement when no input is given.
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()  # Move the character while handling collisions.
