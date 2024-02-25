extends Node

# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of November 2020:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 10567

# Max number of players.
const MAX_PEERS = 12

var peer = null

# Name for my player.
var player_name = "The Warrior"

# Names for remote players in id:name format.
var players = {}
var players_ready = []

# Signals to let lobby GUI know what's going on.
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

var logger: LogStream = LogStream.new(_to_string(), LogStream.LogLevel.DEBUG)


func _to_string() -> String:
	return "gamestate"


func _ready():
	multiplayer.peer_connected.connect(self._player_connected)
	multiplayer.peer_disconnected.connect(self._player_disconnected)
	multiplayer.connected_to_server.connect(self._connected_to_server)
	multiplayer.connection_failed.connect(self._connection_failed)
	multiplayer.server_disconnected.connect(self._server_disconnected)


# Callback from SceneTree.
func _player_connected(id):
	logger.info("Player Connected %s" % [id])
	# Registration of a client beings here, tell the connected player that we are here.
	register_player.rpc_id(id, player_name)


# Callback from SceneTree.
func _player_disconnected(id):
	logger.info("Player Disonnected %s" % [id])
	if has_node("/root/World"): # Game is in progress.
		if multiplayer.is_server():
			game_error.emit("Player " + players[id] + " disconnected")
			end_game()
	else: # Game is not in progress.
		# Unregister this player.
		unregister_player(id)


# Callback from SceneTree, only for clients (not server).
func _connected_to_server():
	logger.info("Successfully connected to server.")
	# We just connected to a server
	connection_succeeded.emit()


# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	game_error.emit("Server disconnected")
	end_game()


# Callback from SceneTree, only for clients (not server).
func _connection_failed():
	logger.warn("Connection failed - removing network peer")
	multiplayer.set_network_peer(null) # Remove peer
	connection_failed.emit()


# Lobby management functions.
@rpc("any_peer")
func register_player(new_player_name):
	var id = multiplayer.get_remote_sender_id()
	players[id] = new_player_name
	player_list_changed.emit()


func unregister_player(id):
	players.erase(id)
	player_list_changed.emit()


@rpc("call_local")
func load_world():
	# Change scene.
	var world = preload("res://world.tscn").instantiate()
	var lobby = get_tree().get_root().get_node("Lobby")
	if lobby:
		get_tree().get_root().add_child(world)
		lobby.hide()
	else:
		get_tree().change_scene_to_packed(world)
	
	get_tree().set_pause(false) # Unpause and unleash the game!


func host_game(new_player_name):
	logger.info("Player '%s' has chosen to host the game" % [new_player_name])
	player_name = new_player_name
	peer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(DEFAULT_PORT, MAX_PEERS)
	if error != OK:
		logger.warn("Cannot host game: %s" % [error])
		return
	
	multiplayer.set_multiplayer_peer(peer)
	logger.info("Waiting for players ...")


func join_game(ip, new_player_name):
	logger.info("New player attempting to join game from IP '%s' with name '%s'" % [
			ip, new_player_name])
	player_name = new_player_name
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, DEFAULT_PORT)
	multiplayer.set_multiplayer_peer(peer)


func get_player_list():
	return players.values()


func get_player_name():
	return player_name


func begin_game():
	assert(multiplayer.is_server())
	load_world.rpc()

	var world = get_tree().get_root().get_node("World")
	var player_scene = load("res://player/player.tscn")

	# Create a dictionary with peer id and respective spawn points, could be improved by randomizing.
	var spawn_points = {}
	spawn_points[1] = 0 # Server in spawn point 0.
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1

	for p_id in spawn_points:
		var spawn_pos = world.get_node("SpawnPoints/" + str(spawn_points[p_id])).position
		var player = player_scene.instantiate()
		player.synced_position = spawn_pos
		player.name = str(p_id)
		logger.info("begin_game -> spawning player '%s' at position %s" %[p_id, spawn_pos])
		player.set_player_name(player_name if p_id == multiplayer.get_unique_id() else players[p_id])
		world.get_node("Players").add_child(player)


func end_game():
	if has_node("/root/World"): # Game is in progress.
		# End it
		get_node("/root/World").queue_free()

	game_ended.emit()
	players.clear()
