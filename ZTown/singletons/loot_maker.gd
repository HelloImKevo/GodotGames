extends Node
## LootMaker

const TINY_COINS = preload("res://loot/tiny_coins.tscn")


func create_coins(host: Node, start_pos: Vector2) -> void:
	var new_tiny_coins = TINY_COINS.instantiate()
	new_tiny_coins.global_position = start_pos
	SceneTreeHelper.add_loot_drop(host, new_tiny_coins)
