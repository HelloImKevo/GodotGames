extends MultiplayerSynchronizer
## player_input.gd

## Copied from "Multiplayer Bomber" Godot sample project:
## https://github.com/godotengine/godot-demo-projects/tree/master/networking/multiplayer_bomber
## Revised based on Godot Scene Replication Tutorial:
## https://godotengine.org/article/multiplayer-in-godot-4-0-scene-replication/


## NOTE: March 4, 2024 - Everything is mostly working correctly.
## Spawned projectiles are shooting in the wrong direction on each client.
## Player GUIs are being propagated everywhere, so those should only
## be instantiated once on each client.

'''
The biggest challenge faced initially was the below error, which was getting
triggered by @export var player_id: int = 0 declared in the player.gd script,
and assigned as a scene_replicator.ALWAYS type.

E 0:00:21:0733   on_sync_receive: Ignoring sync data from non-authority or for missing node.
  <C++ Error>    Condition "true" is true. Continuing.
  <C++ Source>   modules/multiplayer/scene_replication_interface.cpp:879 @ on_sync_receive()
'''

'''
Need to look into this RPC error:

E 0:00:32:0732   _process_rpc: RPC '_shoot_bullet' is not allowed on node /root/Multiplayer/CurrentWorld/World/Players/1976475824 from: 2135132349. Mode is 2, authority is 1.
  <C++ Error>    Condition "!can_call" is true.
  <C++ Source>   modules/multiplayer/scene_rpc_interface.cpp:252 @ _process_rpc()
'''

# Synchronized property.
## Note: It is imperative that this property is added to the MultiplayerSynchronizer
## 'Replication' module in the Godot IDE, with 'Replicate: Always'.
@export var motion: Vector2 = Vector2():
	set(value):
		# This will be sent by players, make sure values are within limits.
		motion = clamp(value, Vector2(-1, -1), Vector2(1, 1)).normalized()

@export var bombing = false

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
		update_shooting.rpc(true)
	
	#if EngineUtils.ui_update_interval():
		#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			#update_shooting.rpc(true)
			#update_shooting.rpc(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT))


@rpc("call_local")
func update_shooting(shooting: bool):
	#if (shooting):
		#Log.info("%s is shooting" % [get_player_string()])
	is_shooting = shooting
	

func get_player_string() -> String:
	return "Player #%s '%s'" % [get_parent().get_player_id(), GameManager.hub.local_client_player_name]


# func get_parent() -> Player:
# 	return get_parent()

#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
	#Log.info("Player '%s' is shooting" % [get_parent().name])
	#shooting_action = true
#else:
	#shooting_action = false
