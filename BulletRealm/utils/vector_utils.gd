class_name VectorUtils


## For use with linear interpolation (lerp) between two Vector2s.
static func get_max_cursor_range_weight(player: Node2D, max_range_px: float) -> float:
	var distance_to_mouse: float = player.global_position.distance_to(
			player.get_global_mouse_position())
	
	if distance_to_mouse > max_range_px:
		return max_range_px / distance_to_mouse
	# 100% of the distance between the player and the mouse position.
	return 1.0
