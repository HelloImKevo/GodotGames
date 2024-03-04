extends Node
## GameManager


# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of November 2020:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 10567

# Max number of players.
const MAX_PEERS = 12

var peer = null

# Signals to let lobby GUI know what's going on.
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

var nav: SceneNav:
	get:
		return nav
	set(new_value):
		nav = new_value

var hub: PlayerHub:
	get:
		return hub
	set(new_value):
		hub = new_value


func _ready():
	_init_children()
	_connect_multiplayer_signals()


func _init_children():
	# Specify each node name, rather than simply "Node@1234".
	nav = SceneNav.new()
	nav.name = "SceneNav"
	add_child(nav, true)
	
	hub = PlayerHub.new()
	hub.name = "PlayerHub"
	# Required for access to the Node-based MultiplayerAPI.
	add_child(hub, true)


func _connect_multiplayer_signals():
	multiplayer.peer_connected.connect(self._player_connected)
	multiplayer.peer_disconnected.connect(self._player_disconnected)
	multiplayer.connected_to_server.connect(self._connected_to_server)
	multiplayer.connection_failed.connect(self._connection_failed)
	multiplayer.server_disconnected.connect(self._server_disconnected)


func _to_string() -> String:
	return "GameManager"


# Callback from SceneTree.
func _player_connected(id):
	Logging.mp.debug("GameManager: Player Connected '%s'. Registering player with rpc_id using name '%s'" % [
			id, hub.local_client_player_name])
	# Registration of a client beings here, tell the connected player that we are here.
	register_player.rpc_id(id, hub.local_client_player_name)


# Lobby management functions.
@rpc("any_peer")
func register_player(new_player_name):
	var remote_player_id = multiplayer.get_remote_sender_id()
	
	hub.players[remote_player_id] = new_player_name
	MPLog.info("GameManager: register_player -> remote_player_id = %s , new_player_name = %s , updated players = %s" % [
			remote_player_id, new_player_name, hub.players])
	player_list_changed.emit()


# Callback from SceneTree.
func _player_disconnected(id):
	Logging.mp.info("GameManager: Player ID %s Disonnected" % [id])
	if has_node("/root/World"):
		# Game is in progress.
		if multiplayer.is_server():
			game_error.emit("Player " + hub.players[id] + " disconnected")
			end_game()
	else:
		# Game is not in progress.
		# Unregister this player.
		unregister_player(id)


func unregister_player(id):
	hub.players.erase(id)
	player_list_changed.emit()


# Callback from SceneTree, only for clients (not server).
func _connected_to_server():
	Logging.mp.info("GameManager: Successfully connected to server.")
	# We just connected to a server
	connection_succeeded.emit()


# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	game_error.emit("Server disconnected")
	end_game()


# Callback from SceneTree, only for clients (not server).
func _connection_failed():
	Logging.mp.warn("GameManager: Connection failed - removing network peer")
	multiplayer.set_network_peer(null) # Remove peer
	connection_failed.emit()


func host_game(host_player_name):
	Logging.mp.info("GameManager: Player '%s' has chosen to host the game -- Creating Server Peer" % [host_player_name])
	hub.local_client_player_name = host_player_name
	peer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(DEFAULT_PORT, MAX_PEERS)
	if error != OK:
		Logging.mp.warn("GameManager: Cannot host game: %s" % [error])
		return
	
	multiplayer.set_multiplayer_peer(peer)


func join_game(ip, new_player_name):
	Logging.mp.info("GameManager: New player attempting to join game from IP '%s' with name '%s' -- Creating Client Peer" % [
			ip, new_player_name])
	hub.local_client_player_name = new_player_name
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, DEFAULT_PORT)
	multiplayer.set_multiplayer_peer(peer)


func end_game():
	if has_node("/root/World"): # Game is in progress.
		# End it
		get_node("/root/World").queue_free()

	game_ended.emit()
	hub.players.clear()
