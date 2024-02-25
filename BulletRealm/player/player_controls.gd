extends Node
## Copied from "Multiplayer Bomber" Godot sample project:
## https://github.com/godotengine/godot-demo-projects/tree/master/networking/multiplayer_bomber


## Note: It is imperative that this property is added to the MultiplayerSynchronizer
## 'Replication' module in the Godot IDE, with 'Replicate: Always'.
@export
var motion = Vector2():
	set(value):
		# This will be sent by players, make sure values are within limits.
		motion = clamp(value, Vector2(-1, -1), Vector2(1, 1)).normalized()

@export var bombing = false
## Is the current client player attempting to shoot a projectile?
@export var shooting_action: bool = false


func capture_client_input():
	var m = Vector2()
	if Input.is_action_pressed("move_left"):
		m += Vector2(-1, 0)
	if Input.is_action_pressed("move_right"):
		m += Vector2(1, 0)
	if Input.is_action_pressed("move_up"):
		m += Vector2(0, -1)
	if Input.is_action_pressed("move_down"):
		m += Vector2(0, 1)

	motion = m
	#bombing = Input.is_action_pressed("set_bomb")
	
	# This will need to be updated for GUI mouse click interception.
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		shooting_action = true
	else:
		shooting_action = false
