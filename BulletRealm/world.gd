class_name World
extends Node2D
## World : Main world hub that logged-in players spawn into.


var logger: LogStream = LogStream.new("World", LogStream.LogLevel.DEBUG)


func _ready():
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	
	if not multiplayer.is_server():
		MPLog.debug("I, %s, am not the server. Skipping world player spawn.")
		# TODO: Players are not being spawned in on clients other than the Host server.
		return # TODO: Show player info anyways
	
	MPLog.info("World._ready: my_name = %s , get_all_player_names = %s" % [
			GameManager.hub.local_client_player_name, GameManager.hub.get_all_player_names()])
	
	# TODO: Convert this to a Dictionary of all players and all their names.
	# Spawn already connected players
	for remote_player_id in multiplayer.get_peers():
		var player_name: String = GameManager.hub.get_remote_player_name(remote_player_id)
		add_player(remote_player_id, player_name)
	
	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		var host_player_name = GameManager.hub.local_client_player_name
		add_player(1, host_player_name)
	
	show_players()


func _process(_delta):
	# TODO: This will quit the game for all players.
	if Input.is_action_just_pressed("quit"):
		GameManager.nav.load_main_scene()


func add_player(id: int, player_name: String):
	var player_scene = load("res://player/player.tscn")
	
	# TODO: Need to check if a player is already nearby this spawn point, and use a different
	# one. But Player-Player collisions have been turned off, so it should be fine.
	var spawn_points: Array = get_node("SpawnPoints").get_children()
	var rand_spawn_point: Node = spawn_points.pick_random()
	
	# TODO: Come up with better spawning -- this is quick hackery.
	# Randomize character position.
	var player: Player = player_scene.instantiate()
	player.player_id = id
	
	var pos: Vector2 = rand_spawn_point.position
	player.position = pos
	player.synced_position = pos
	# Set the name of the node.
	player.name = "Player#%s" % [id]
	player.set_player_name(player_name)
	$Players.add_child(player, true)


func del_player(player_id: int):
	# TODO: This approach is brittle.
	if not $Players.has_node(str(player_id)):
		return
	$Players.get_node(str(player_id)).queue_free()


func show_players():
	var player_names: Array = GameManager.hub.get_all_player_names()
	var msg: String = ""
	var count: int = 1
	for pn in player_names:
		if count > 1:
			msg += "\n"
		msg += "Player #%s: %s" % [count, pn]
		count += 1
	
	if multiplayer.is_server():
		msg = "You are the host.\n" + msg
	
	$CanvasLayer/PlayerList.text = msg


# TODO: This will probably need to be used in other places.
func _get_current_player() -> Player:
	for player in $Players.get_children():
		if self.is_multiplayer_authority() and player.is_multiplayer_authority():
			return player
		
		if player.name == str(multiplayer.get_unique_id()):
			return player
	
	return null
