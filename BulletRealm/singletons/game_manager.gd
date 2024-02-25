extends Node
## GameManager

const MAIN_LOGIN: PackedScene = preload("res://main_login/main_login.tscn")
const WORLD: PackedScene = preload("res://world.tscn")
const LOBBY: PackedScene = preload("res://main_login/lobby.tscn")
const TEST_LEVEL: PackedScene = preload("res://test_level/test_level.tscn")

var start_singleplayer_game: bool

# Track number of players connected to host.
var players: Dictionary = {}


func is_singleplayer() -> bool:
	return multiplayer.multiplayer_peer == null


func load_main_scene():
	get_tree().change_scene_to_packed(MAIN_LOGIN)


func load_test_level_scene():
	get_tree().change_scene_to_packed(TEST_LEVEL)


func load_lobby_scene():
	get_tree().change_scene_to_packed(LOBBY)
