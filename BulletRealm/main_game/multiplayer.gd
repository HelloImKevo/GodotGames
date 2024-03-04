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
	
	# Start paused.
	# get_tree().paused = true ???
	
	# This seems to have been the root cause of lobby sync issues.
	# You can save bandwith by disabling server relay and peer notifications.
	#multiplayer.server_relay = false
	
	# Automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless":
		Logging.mp.info("Automatically starting dedicated server")
		_auto_start_dedicated_server.call_deferred()


func change_level(scene: PackedScene):
	# Remove old level if any.
	var level = $CurrentWorld
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	# Add new level.
	level.add_child(scene.instantiate())


func start_multiplayer_game():
	MPLog.info("Multiplayer.start_multiplayer_game invoked.")
	# Hide the UI and unpause to start the game.
	# TODO: Lobby is not being hidden for all clients!
	lobby.hide()
	# get_tree().paused = false
	# Only change level on the server.
	# Clients will instantiate the level via the spawner.
	if multiplayer.is_server():
		MPLog.info("Multiplayer.is_server --> Loading World ...")
		change_level.call_deferred(load("res://world.tscn"))


func _auto_start_dedicated_server():
	var p_name: String = lobby.get_player_name()
	GameManager.host_game(p_name)
