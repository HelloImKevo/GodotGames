class_name LootContainer
extends StaticBody2D
## A static physics body that cannot be moved. Has a circular "interaction" region
## that captures 'Interact' input from players to open or inspect the container.

@onready var interact_area: Area2D = $InteractArea

## An array of spawn points for loot that is produced.
@export var spawn_points: Array[Marker2D] = []


func _ready():
	# If spawn points is empty, automatically populate it with the
	# markers specified in our SpawnPoints container.
	if spawn_points.is_empty():
		for spawn_point in $SpawnPoints.get_children():
			spawn_points.append(spawn_point)


func _physics_process(_delta):
	_physics_handle_area_collisions()


func _physics_handle_area_collisions() -> void:
	# Check if a player is nearby.
	if AreaUtils.is_player_in_region(interact_area):
		var nearest: Player = VectorUtils.get_nearest_player(self)
		# Check if a nearby player is pressing the 'Interact' action.
		if nearest.get_player_input().is_interact_just_pressed():
			_spawn_coins()


func _spawn_coins() -> void:
	var point: Node2D = spawn_points.pick_random()
	LootMaker.create_coins(self, point.global_position)
