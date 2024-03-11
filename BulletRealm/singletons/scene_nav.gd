class_name SceneNav
extends Node
## Instantiate using new() and add as a child to [GameManager].


const MAIN_LOGIN: PackedScene = preload("res://main_login/main_login.tscn")
const WORLD: PackedScene = preload("res://world.tscn")
const LOBBY: PackedScene = preload("res://main_login/lobby.tscn")
const TEST_LEVEL: PackedScene = preload("res://test_level/test_level.tscn")


func _to_string() -> String:
	return "SceneNav"


func load_main_scene():
	get_tree().change_scene_to_packed(MAIN_LOGIN)


func load_test_level_scene():
	get_tree().change_scene_to_packed(TEST_LEVEL)


func load_lobby_scene():
	get_tree().change_scene_to_packed(LOBBY)


func load_singleplayer_scene():
	get_tree().change_scene_to_packed(load("res://main_game/singleplayer.tscn"))


func load_multiplayer_scene():
	get_tree().change_scene_to_packed(load("res://main_game/multiplayer.tscn"))
