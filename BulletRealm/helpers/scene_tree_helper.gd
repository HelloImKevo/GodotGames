class_name SceneTreeHelper


static func add_projectile(host: Node, child: Node2D) -> void:
	host.get_tree().root.find_child("Projectiles", true, false).add_child(child)
