class_name MainLogin
extends Node2D
## MainLogin : Main Menu entry point for the game. Users can Login to the Character
## Selection Screen, Change Settings, View Credits or Exit the Game.


@onready var settings_panel = $CanvasLayer/SettingsPanel


func _ready():
	Settings.reset_to_configured_game_volume()


func _on_btn_login_pressed():
	GameManager.load_test_level_scene()


func _on_btn_settings_pressed():
	# For this to work, it would have to be added as a child of the CanvasLayer,
	# otherwise the Origin of the settings panel is centered on the top-left corner
	# of the screen.
	#var panel = settings_panel.instantiate()
	#self.add_child(panel)
	settings_panel.show()


func _on_btn_credits_pressed():
	print("Credits not implemented")


func _on_btn_exit_pressed():
	get_tree().quit()
