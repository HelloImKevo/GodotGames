extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


@export var player: CharacterBody2D
@onready var camera = $Camera2D

var shake_intensity = 0.0

func _process(delta):
	if player:
		var camera_speed = 5.0  # Adjust for smoothness
		global_position = global_position.lerp(player.global_position, camera_speed * delta)
		
		# Apply random shake
		if shake_intensity > 0:
			global_position += Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
			shake_intensity = max(shake_intensity - delta * 5, 0)


func apply_shake(intensity):
	shake_intensity = intensity
