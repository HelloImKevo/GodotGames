class_name VectorUtils


## For use with linear interpolation (lerp) between two Vector2s.
static func get_max_cursor_range_weight(player: Node2D, max_range_px: float) -> float:
	var distance_to_mouse: float = player.global_position.distance_to(
			player.get_global_mouse_position())
	
	if distance_to_mouse > max_range_px:
		return max_range_px / distance_to_mouse
	# 100% of the distance between the player and the mouse position.
	return 1.0


## Returns the [Player] closest to the [host] node, or null if no player was found
## (this should only happen if used in the context of a cutscene, or a menu, or some
## kind of scripted scene).
static func get_nearest_player(host: Node2D) -> Player:
	var nearest: Player = null
	for player in host.get_tree().get_nodes_in_group(Identifier.GROUP_PLAYER):
		if nearest == null:
			nearest = player
		
		var snap_amt: float = 0.5
		var nearest_distance: float = snappedf(node_distance_to(host, nearest), snap_amt)
		var current_distance: float = snappedf(node_distance_to(host, player), snap_amt)
		if current_distance < nearest_distance:
			nearest = player
	
	return nearest


## Returns the absolute value (always positive) of the distance between the two nodes.
static func node_distance_to(node: Node2D, target: Node2D) -> float:
	return abs(node.global_position.distance_to(target.global_position))
