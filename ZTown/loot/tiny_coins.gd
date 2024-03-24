class_name TinyCoins
extends Area2D


var _time_alive: float = 0.0
# Make sure this can only be picked up one time during physics time steps.
var _is_picked_up: bool = false


func _ready():
	$Sound.play()


func _process(delta):
	_time_alive += delta


func _physics_process(_delta):
	_physics_handle_player_pickup()


func _physics_handle_player_pickup() -> void:
	# TODO: This would need to be reworked if we want some kind of
	# magnetic loot pickup mechanic.
	if AreaUtils.is_player_in_region(self):
		var player: Player = VectorUtils.get_nearest_player(self)
		if player == null:
			# This should never happen.
			return
		
		# Only perform the pickup if the player is currently moving (to avoid)
		# an immediate auto-pickup when coins are first spawned.
		if not _is_picked_up and player.velocity != Vector2.ZERO and _time_alive > 0.5:
			# TODO: The loot needs to go into the player's inventory. It might be better
			# to put this logic into the player, rather than relying on messy signals.
			_is_picked_up = true
			$Sound.play()
			await get_tree().create_timer(0.3).timeout
			queue_free()
