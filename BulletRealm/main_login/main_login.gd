class_name MainLogin
extends Node2D
## MainLogin : Main Menu entry point for the game. Users can Login to the Character
## Selection Screen, Change Settings, View Credits or Exit the Game.


# TODO: Wire up the Settings and Exit buttons.
@onready var music = $Music


func _ready():
	music.volume_db = Settings.get_music_volume()
