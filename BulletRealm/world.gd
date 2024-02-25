class_name World
extends Node2D
## World : Main world hub that logged-in players spawn into.


@export var player: PackedScene = preload("res://player/player.tscn")

@onready var player_cam: Camera2D = $PlayerCam

var logger: LogStream = LogStream.new("World", LogStream.LogLevel.DEBUG)


func _process(_delta):
	# TODO: This will quit the game for all players.
	if Input.is_action_just_pressed("quit"):
		GameManager.load_main_scene()
	
	# Anchor the 2D camera viewport to the player's position.
	# We want all the physics processing to be calculated before
	# the camera starts moving around. Moving the camera in _physics_process
	# results in horrible stuttering.
	var player: Player = _get_current_player()
	if player:
		# TODO: The camera is stuttering. Only one camera instance should be created
		# on the client, and it should always follow the client player.
		var offset: Vector2 = player.get_camera_offset()
		player_cam.position = player.position
		player_cam.offset = offset


# TODO: This will probably need to be used in other places.
func _get_current_player() -> Player:
	for player in $Players.get_children():
		if self.is_multiplayer_authority() and player.is_multiplayer_authority():
			return player
		
		if player.name == str(multiplayer.get_unique_id()):
			return player
	
	return null

# logger.info("my_unique_id = %s" % [multiplayer.get_unique_id()])
# logger.debug("player.name = %s , is_mp_authority = %s" % [player.name, player.is_multiplayer_authority()])
# logger.info("found matching player: %s" % [player.name])
