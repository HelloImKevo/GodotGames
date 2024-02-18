class_name TweenUtils


static func kill_tween(tween: Tween) -> void:
	if tween != null:
		tween.kill()


static func tween_fade_away(canvas_item: CanvasItem, duration: float) -> Tween:
	var tween: Tween = canvas_item.get_tree().create_tween()
	tween.tween_property(canvas_item, "self_modulate", Color.TRANSPARENT, duration)
	return tween


static func tween_flash_red(node: Node2D, duration: float) -> Tween:
	var tween: Tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(node, "self_modulate", Color.RED, 0.3)
	tween.tween_property(node, "self_modulate", Color.WHITE, 0.3)
	return tween


static func tween_move_in_direction(node: Node2D, dir: Vector2) -> Tween:
	var tween: Tween = node.get_tree().create_tween()
	tween.tween_property(node, "position.y", dir.y, 1.0)
	return tween


static func tween_rotate_back_and_forth(node: Node2D, tween: Tween, angle: float) -> void:
	tween.set_loops()
	tween.tween_property(node, "rotation", deg_to_rad(node.rotation_degrees - angle), 0.3)
	tween.tween_property(node, "rotation", deg_to_rad(node.rotation_degrees), 0.3)
	tween.tween_property(node, "rotation", deg_to_rad(node.rotation_degrees + angle), 0.3)
	tween.tween_property(node, "rotation", deg_to_rad(node.rotation_degrees), 0.3)


static func tween_loop_frames(sprite: Sprite2D, frames: Array, duration: float) -> Tween:
	var tween: Tween = sprite.get_tree().create_tween()
	tween.set_loops()
	for frame: int in frames:
		tween.tween_property(sprite, "frame", frame, duration)
	
	return tween
