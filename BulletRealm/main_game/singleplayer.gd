class_name Singleplayer
extends Node


func _ready():
	change_level(load("res://world.tscn"))


func change_level(scene: PackedScene):
	# Remove old level if any.
	var level = $CurrentWorld
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	# Add new level.
	level.add_child(scene.instantiate())
