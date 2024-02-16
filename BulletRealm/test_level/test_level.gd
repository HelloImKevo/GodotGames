class_name TestLevel
extends Node2D


func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		GameManager.load_main_scene()
