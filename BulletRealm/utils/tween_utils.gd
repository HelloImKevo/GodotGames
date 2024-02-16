class_name TweenUtils


static func tween_fade_away(node: Node2D, duration: float) -> Tween:
	var tween: Tween = node.get_tree().create_tween()
	tween.tween_property(node, "self_modulate", Color.TRANSPARENT, duration)
	return tween


static func tween_rotate_back_and_forth(node: Node2D, tween: Tween, angle: float) -> void:
	tween.set_loops()
	tween.tween_property(node, "rotation", deg_to_rad(node.rotation_degrees - angle), 0.3)
	tween.tween_property(node, "rotation", deg_to_rad(node.rotation_degrees), 0.3)
	tween.tween_property(node, "rotation", deg_to_rad(node.rotation_degrees + angle), 0.3)
	tween.tween_property(node, "rotation", deg_to_rad(node.rotation_degrees), 0.3)
