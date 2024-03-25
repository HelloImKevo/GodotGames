class_name PlayerInput
extends Node
## player_input.gd

## Copied from "Multiplayer Bomber" Godot sample project:
## https://github.com/godotengine/godot-demo-projects/tree/master/networking/multiplayer_bomber
## Revised based on Godot Scene Replication Tutorial:
## https://godotengine.org/article/multiplayer-in-godot-4-0-scene-replication/

## Defaults to -1 representing Keyboard and Mouse.
@export var device_input_id: int = -1

# Synchronized property.
@export var motion: Vector2 = Vector2():
	set(value):
		# This will be sent by players, make sure values are within limits.
		motion = clamp(value, Vector2(-1, -1), Vector2(1, 1)).normalized()

# Set via RPC to simulate is_action_just_pressed.
## Is the current client player attempting to shoot a projectile?
@export var is_shooting: bool = false

## Did the player just jump?
@export var jumped: bool = false


func set_device_input_id(device: int) -> void:
	device_input_id = device


## Call within the process or physics_process function of a [Player] node.
## device is the [DeviceInput] ID. -1 for Keyboard, 0 - 3 for controllers.
func capture_client_input():
	var m = Vector2()
	if MultiplayerInput.is_action_pressed(device_input_id, "move_left"):
		m += Vector2(-1, 0)
	if MultiplayerInput.is_action_pressed(device_input_id, "move_right"):
		m += Vector2(1, 0)
	if MultiplayerInput.is_action_pressed(device_input_id, "move_up"):
		m += Vector2(0, -1)
	if MultiplayerInput.is_action_pressed(device_input_id, "move_down"):
		m += Vector2(0, 1)

	motion = m
	
	# This will need to be updated for GUI mouse click interception.
	# TODO: Need to check mouse position, if it is within constraints of game window.
	# TODO: This RPC is being spammed way too frequently.
	if MultiplayerInput.is_action_just_pressed(device_input_id, "primary_action"):
		update_shooting(true)
	
	if MultiplayerInput.is_action_just_pressed(device_input_id, "jump"):
		jumped = true
	
	#if EngineUtils.ui_update_interval():
		#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			#update_shooting.rpc(true)
			#update_shooting.rpc(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT))


func is_interact_just_pressed() -> bool:
	return MultiplayerInput.is_action_just_pressed(device_input_id, "interact")


func update_shooting(shooting: bool):
	#if (shooting):
		#Log.info("%s is shooting" % [get_player_string()])
	is_shooting = shooting
	

func get_player_string() -> String:
	return "Player #%s '%s'" % [get_parent().get_player_id(), GameManager.hub.local_client_player_name]
