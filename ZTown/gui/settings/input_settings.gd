extends Control
## InputSettings, Keybindings, Keymap GUI
## Credits: DashNothing - Easy Input Settings Menu


@onready var input_button_scene = preload("res://gui/settings/input_button.tscn")
@onready var action_list = $PanelContainer/MC/VB/ScrollView/ActionList

var is_remapping = false
var action_to_remap = null
var remapping_button = null

# TODO: Support localization
var input_actions: Dictionary = {
	"move_up": "Move Up",
	"move_left": "Move Left",
	"move_down": "Move Down",
	"move_right": "Move Right",
	"shoot": "Shoot"
	
	#TODO: Not supported yet
	#"jump": "Jump",
	#"primary_action": "Primary Action",
	#"secondary_action": "Secondary Action",
	#"interact": "Interact",
	#"pause_menu": "Pause Menu",
	#"radial_menu": "Radial Menu"
}


# Called when the node enters the scene tree for the first time.
func _ready():
	_create_action_list()


func _create_action_list():
	InputMap.load_from_project_settings()
	for item in action_list.get_children():
		item.queue_free()
	
	# Note: You can use InputMap.get_actions() for a list of
	# all Godot input actions.
	for action in input_actions:
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("LabelInput")
		
		action_label.text = input_actions[action]
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""
		
		action_list.add_child(button)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))


func _on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text = "Press key to bind..."


func _input(event):
	if is_remapping:
		if (
			event is InputEventKey ||
			(event is InputEventMouseButton and event.pressed)
		):
			# Turn double click into single click.
			if event is InputEventMouseButton and event.double_click:
				event.double_click = false
			
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			_update_action_list(remapping_button, event)
			
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			
			accept_event()


func _update_action_list(button, event):
	# Remove the 'W (Physical)' suffix.
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")


func _on_reset_button_pressed():
	# Re-create the action list.
	_create_action_list()


func _on_accept_button_pressed():
	# TODO: Save settings.
	self.hide()
