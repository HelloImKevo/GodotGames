class_name SceneTreeHelper


static func add_projectile(host: Node, child: Node2D) -> void:
	host.get_tree().root.find_child("Projectiles", true, false).add_child(child)


static func add_loot_drop(host: Node, child: Node2D) -> void:
	host.get_tree().root.find_child("LootDrops", true, false).add_child(child)
