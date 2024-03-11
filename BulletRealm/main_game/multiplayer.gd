extends Node
## Multiplayer game engine. Name must not conflict with MultiplayerAPI.


@onready var lobby: Lobby = $Lobby


func _ready():
	# Called every time the node is added to the scene.
	GameManager.connection_failed.connect(lobby.on_connection_failed)
	GameManager.connection_succeeded.connect(lobby.on_connection_success)
	GameManager.player_list_changed.connect(lobby.refresh_lobby)
	GameManager.game_ended.connect(lobby.on_game_ended)
	GameManager.game_error.connect(lobby.on_game_error)
	GameManager.world_loading.connect(self._on_world_loading)
	GameManager.world_loaded.connect(self._on_world_loaded)
	
	# This seems to have been the root cause of lobby sync issues.
	# You can save bandwith by disabling server relay and peer notifications.
	#multiplayer.server_relay = false
	
	# Automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless":
		Logging.mp.info("Automatically starting dedicated server")
		_auto_start_dedicated_server.call_deferred()


func start_multiplayer_game():
	assert(multiplayer.is_server())
	MPLog.info("Multiplayer.start_multiplayer_game invoked by Host server.")
	# get_tree().paused = false
	# Only change level on the server.
	# Clients will instantiate the level via the spawner.
	if multiplayer.is_server():
		MPLog.info("Multiplayer.is_server --> Loading World ...")
		GameManager.world_loading.emit()
		change_level.rpc()


## The server governs when worlds can be loaded. This approach might not work
## for an MMO-style game (where a player can log into an empty instance of a
## world). Instruct each client to load the main game world.
## NOTE: RPC does not support passing of complex object types like PackedScene.
@rpc("call_local", "reliable")
func change_level():
	if multiplayer.is_server():
		# NOTE: I don't think this is necessary - it was the Player:player_id sync property
		# Use a coroutine to wait for a bit.
		await get_tree().create_timer(0.2).timeout
	# NOTE: MultiplayerSpawner is designed for Server -> Client propagation.
	# Clients must have their World instantiated BEFORE the server. This could
	# be accomplished with a "Ready!" state, where clients let the Server know
	# their local world is finished loading.
	# This should always get invoked by the authority remote_sender_id(1)
	MPLog.debug("change_level invoked by peer: %s" % [multiplayer.get_remote_sender_id()])
	
	var world: PackedScene = load("res://world.tscn")
	
	# Remove old level if any.
	var level = $CurrentWorld
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	
	# Add new level.
	level.add_child(world.instantiate(), true)
	get_tree().set_pause(false) # Unpause and unleash the game!


func _auto_start_dedicated_server():
	var p_name: String = lobby.get_player_name()
	GameManager.host_game(p_name)


func _on_world_loading() -> void:
	MPLog.debug("Multiplayer -> on_world_loading ...")


func _on_world_loaded() -> void:
	MPLog.debug("Multiplayer -> on_world_loaded. Hiding Lobby.")
	lobby.hide()
