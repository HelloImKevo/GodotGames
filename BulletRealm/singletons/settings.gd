extends Node
## Settings : Singleton that manages user-specific settings, like SFX and Music volume.
# TODO: Consider making this a C# class with getters/setters for all the Settings.


const SETTINGS_FILE: String = "user://settings.dat"

var _settings: Dictionary = {}


func _ready():
	_load_settings()


## Sound Effects volume, in decibels.
func get_sfx_volume() -> float:
	return -20.0


## Music volume, in decibels.
func get_music_volume() -> float:
	return -20.0


func save_settings() -> void:
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(_settings))


## Example: { "sfx_volume": -20.0, "music_volume": -10.0 }
func _load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_FILE):
		return
	
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
	_settings = JSON.parse_string(file.get_as_text())
	# TODO: GodotLogger
	print("_load_settings(): ", _settings)
