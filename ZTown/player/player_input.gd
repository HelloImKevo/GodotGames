extends Node
## player_input.gd

## Copied from "Multiplayer Bomber" Godot sample project:
## https://github.com/godotengine/godot-demo-projects/tree/master/networking/multiplayer_bomber
## Revised based on Godot Scene Replication Tutorial:
## https://godotengine.org/article/multiplayer-in-godot-4-0-scene-replication/

# Synchronized property.
@export var motion: Vector2 = Vector2():
	set(value):
		# This will be sent by players, make sure values are within limits.
		motion = clamp(value, Vector2(-1, -1), Vector2(1, 1)).normalized()

# Set via RPC to simulate is_action_just_pressed.
## Is the current client player attempting to shoot a projectile?
@export var is_shooting: bool = false


func _ready():
	var should_process: bool = get_parent().get_player_id() == multiplayer.get_unique_id()
	set_process(should_process)
	
	if should_process:
		MPLog.info("PlayerInput _ready -> I, %s, SHOULD PROCESS because I match mp.unique_id %s" % [
				get_player_string(), multiplayer.get_unique_id()
		])
	
	MPLog.info("PlayerInput _ready -> Am I, %s, the MP Authority? %s" % [
			get_player_string(), is_multiplayer_authority()
	])


func _process(_delta):
	capture_client_input()


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
	
	# This will need to be updated for GUI mouse click interception.
	# TODO: Need to check mouse position, if it is within constraints of game window.
	# TODO: This RPC is being spammed way too frequently.
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		update_shooting(true)
	
	#if EngineUtils.ui_update_interval():
		#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			#update_shooting.rpc(true)
			#update_shooting.rpc(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT))


func update_shooting(shooting: bool):
	#if (shooting):
		#Log.info("%s is shooting" % [get_player_string()])
	is_shooting = shooting
	

func get_player_string() -> String:
	return "Player #%s '%s'" % [get_parent().get_player_id(), GameManager.hub.local_client_player_name]
