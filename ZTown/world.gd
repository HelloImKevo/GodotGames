class_name World
extends Node2D
## World : Main world hub that logged-in players spawn into.

@onready var players: Node2D = $Players

@onready var player_cam: Camera2D = $PlayerCam
@onready var player_gui = $PlayerGUI

var logger: LogStream = LogStream.new("World", LogStream.LogLevel.DEBUG)


func _ready():
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	
	GUIManager.toggle_player_status_panel_visibility.connect(_toggle_player_status_panel_visibility)
	
	GameManager.world_loaded.emit()
	
	if multiplayer.is_server():
		handle_spawn_players()
	
	# Temporarily auto-showing GUI for testing purposes.
	player_gui.show_status_panel()
	player_gui.show_connected_player_info()


func handle_spawn_players() -> void:
	MPLog.info("World._ready: my_name = %s , get_all_player_names = %s" % [
			GameManager.hub.local_client_player_name, GameManager.hub.get_all_player_names()])
	
	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		# TODO: This is for temporary testing of the MultiplayerInput plugin.
		spawn_local_coop_players()
		#var host_player_name = GameManager.hub.local_client_player_name
		#add_player(1, host_player_name)
	
	# TODO: Convert this to a Dictionary of all players and all their names.
	# Spawn already connected players
	for remote_player_id in multiplayer.get_peers():
		var player_name: String = GameManager.hub.get_remote_player_name(remote_player_id)
		#add_player(remote_player_id, player_name)


func spawn_local_coop_players() -> void:
	var p1_num: int = 1
	var p1_device_input = -1
	var p1_name: String = "Keyboard (P1)"
	add_player(p1_num, p1_device_input, p1_name)
	# Join keyboard player.
	PlayerManager.join(p1_device_input, p1_name)
	
	var p2_num: int = 2
	var p2_device_input = 0
	var p2_name: String = "Controller (P2)"
	#add_player(p2_num, p2_device_input, p2_name)
	# Join controller player.
	# TODO: This will crash if a 2nd input device is not present.
	#PlayerManager.join(p2_device_input, p2_name)


func add_player(player_number: int, device_input_id: int, player_name: String):
	var player_scene: PackedScene = load("res://player/player.tscn")
	
	# TODO: Need to check if a player is already nearby this spawn point, and use a different
	# one. But Player-Player collisions have been turned off, so it should be fine.
	var spawn_points: Array = get_node("SpawnPoints").get_children()
	var rand_spawn_point: Node = spawn_points.pick_random()
	
	# TODO: Come up with better spawning -- this is quick hackery.
	# Randomize character position.
	var player: Player = player_scene.instantiate()
	
	# NOTE: It's imperative that players don't spawn into a collision, like an NPC.
	var rand_variance: Vector2 = Vector2(randf_range(0.0, 100.0), randf_range(0.0, 100.0))
	var pos: Vector2 = rand_spawn_point.position + rand_variance
	player.position = pos
	# Set the name of the node. Multiplayer sychronizers are currently dependent
	# on this Node name being propagated across peers.
	player.init(player_number, device_input_id, player_name)
	player.name = str(player_number)
	# NOTE: Nope, I'm wrong. It was the Player.player_id synchronizer property.
	# NOTE: Multiplayer Synchronizer does not work well with the $Players
	# member reference syntax. Use get_node("String") instead.
	$Players.add_child(player, true)


func del_player(player_id: int):
	# TODO: This approach is brittle.
	if not $Players.has_node(str(player_id)):
		return
	$Players.get_node(str(player_id)).queue_free()


func _process(_delta):
	_process_handle_player_cam()
	
	# TODO: This will quit the game for all players.
	if Input.is_action_just_pressed("quit"):
		GameManager.nav.load_main_scene()


func _process_handle_player_cam() -> void:
	var players: Array[Node] = players.get_children()
	if players.is_empty():
		return
	
	var center_point: Vector2 = VectorUtils.get_center_point_of(players)
	
	# Anchor the 2D camera viewport to the player's position.
	# We want all the physics processing to be calculated before
	# the camera starts moving around.
	player_cam.position = center_point


func _toggle_player_status_panel_visibility() -> void:
	player_gui.show_status_panel()


# TODO: This will probably need to be used in other places.
func _get_current_player() -> Player:
	for player in $Players.get_children():
		if self.is_multiplayer_authority() and player.is_multiplayer_authority():
			return player
		
		if player.name == str(multiplayer.get_unique_id()):
			return player
	
	return null
