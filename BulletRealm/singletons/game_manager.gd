extends Node
## GameManager

const MAIN_LOGIN: PackedScene = preload("res://main_login/main_login.tscn")
const TEST_LEVEL: PackedScene = preload("res://test_level/test_level.tscn")


func load_main_scene():
	get_tree().change_scene_to_packed(MAIN_LOGIN)


func load_test_level_scene():
	get_tree().change_scene_to_packed(TEST_LEVEL)
