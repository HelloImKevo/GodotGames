class_name SettingsPanel
extends Control
## Read more about Audio Buses and the [AudioServer] here:
## https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html


var sound = AudioServer.get_bus_index("Sound")
var music = AudioServer.get_bus_index("Music")

@onready var sfx_slider = $MC/InnerMC/VBoxStack/HB/SfxSlider
@onready var music_slider = $MC/InnerMC/VBoxStack/HB2/MusicSlider

var _sfx_slider_db: float = 0.0
var _music_slider_db: float = 0.0


func _on_btn_cancel_pressed():
	Settings.reset_to_configured_game_volume()
	self.hide()


func _on_btn_save_pressed():
	Settings.update_setting(Settings.SFX_VOLUME, _sfx_slider_db)
	Settings.update_setting(Settings.MUSIC_VOLUME, _music_slider_db)
	Settings.save_settings()
	self.hide()


func _on_sfx_slider_value_changed(value):
	_sfx_slider_db = AudioUtils.linear_to_db_min(value)
	AudioServer.set_bus_volume_db(sound, AudioUtils.linear_to_db_min(value))


func _on_music_slider_value_changed(value):
	_music_slider_db = AudioUtils.linear_to_db_min(value)
	AudioServer.set_bus_volume_db(music, AudioUtils.linear_to_db_min(value))


func _on_visibility_changed():
	if not is_visible():
		# Settings panel is only active when made visible from a host scene.
		return

	# Reset defaults when Settings panel is hidden.
	_sfx_slider_db = Settings.get_sfx_volume_db()
	_music_slider_db = Settings.get_music_volume_db()
	
	sfx_slider.set_value_no_signal(db_to_linear(_sfx_slider_db))
	music_slider.set_value_no_signal(db_to_linear(_music_slider_db))
