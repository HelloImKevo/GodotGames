extends Node
## GameManager Singleton

# Signals to let lobby GUI know what's going on.
signal player_list_changed()
signal game_ended()
signal game_error(what)
## When the [World] is being loaded. At this point, each client
## could hide its Lobby or show a splash screen.
signal world_loading
signal world_loaded

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


func _init_children():
	# Specify each node name, rather than simply "Node@1234".
	nav = SceneNav.new()
	nav.name = "SceneNav"
	add_child(nav, true)
	
	hub = PlayerHub.new()
	hub.name = "PlayerHub"
	# Required for access to the Node-based MultiplayerAPI.
	add_child(hub, true)


func _to_string() -> String:
	return "GameManager"


func unregister_player(id):
	hub.players.erase(id)
	player_list_changed.emit()


func end_game():
	if has_node("/root/World"): # Game is in progress.
		# End it
		get_node("/root/World").queue_free()

	game_ended.emit()
	hub.players.clear()
