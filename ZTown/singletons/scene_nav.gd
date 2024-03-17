class_name SceneNav
extends Node
## Instantiate using new() and add as a child to [GameManager].


const WORLD: PackedScene = preload("res://world.tscn")
const TEST_LEVEL: PackedScene = preload("res://test_level/test_level.tscn")


func _to_string() -> String:
	return "SceneNav"


func load_main_scene():
	get_tree().change_scene_to_packed(load("res://main_game/main_menu.tscn"))


func load_singleplayer_scene():
	get_tree().change_scene_to_packed(load("res://main_game/main_game.tscn"))


func load_test_level_scene():
	get_tree().change_scene_to_packed(TEST_LEVEL)
