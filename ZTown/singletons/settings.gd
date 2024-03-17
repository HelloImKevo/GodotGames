extends Node
## Settings : Singleton that manages user-specific settings, like SFX and Music volume.
# TODO: Consider making this a C# class with getters/setters for all the Settings.


const SETTINGS_FILE: String = "user://settings.dat"

const SFX_VOLUME = "sfx_volume"
const MUSIC_VOLUME = "music_volume"

var _settings: Dictionary = {}


func _ready():
	_load_settings()


func reset_to_configured_game_volume() -> void:
	var music = AudioServer.get_bus_index("Music")
	var sound = AudioServer.get_bus_index("Sound")
	
	AudioServer.set_bus_volume_db(music, get_music_volume_db())
	AudioServer.set_bus_volume_db(sound, get_sfx_volume_db())


## Sound Effects volume, in decibels.
## -80 = Off
## -30 = Low
## -10 = Normal
## 0 = High
func get_sfx_volume_db() -> float:
	return _settings[SFX_VOLUME]


## Music volume, in decibels.
## -80 = Off
## -30 = Low
## -10 = Normal
## 0 = High
func get_music_volume_db() -> float:
	return _settings[MUSIC_VOLUME]


## Updates in-memory settings. You must explicitly call [save_settings].
func update_setting(key: String, value):
	if typeof(value) == TYPE_FLOAT:
		_settings[key] = snappedf(value, 0.01)
	else:
		print("Setting not saved! ", key)


func save_settings() -> void:
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	var json = JSON.stringify(_settings)
	print("save_settings() = ", json)
	file.store_string(json)


func _add_default_if_needed(key: String, value):
	if not key in _settings:
		update_setting(key, value)


## Example: { "sfx_volume": -20.0, "music_volume": -10.0 }
func _load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_FILE):
		_apply_in_memory_defaults()
		return
	
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
	_settings = JSON.parse_string(file.get_as_text())
	_apply_in_memory_defaults()
	Log.info("_load_settings(): %s" % _settings)


func _apply_in_memory_defaults():
	_add_default_if_needed(SFX_VOLUME, -10.0)
	_add_default_if_needed(MUSIC_VOLUME, -10.0)
