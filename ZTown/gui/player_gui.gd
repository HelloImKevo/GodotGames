class_name PlayerGUI
extends CanvasLayer
## PlayerGUI : Contains core resources (Health, Mana, Experience) and a detailed
## status panel, all displayed on the local client.

@onready var player_status_panel: PlayerStatusPanel = $PlayerStatusPanel
@onready var player_list = $PlayerList


func _ready():
	GUIManager.toggle_player_status_panel_visibility.connect(_toggle_player_status_panel_visibility)
	GUIManager.on_player_attributes_updated.connect(update_attrs)
	GUIManager.on_player_status_effects_updated.connect(update_status_effects)


#region Player Status Panel

func get_status_panel() -> PlayerStatusPanel:
	return player_status_panel


func _toggle_player_status_panel_visibility():
	var status_panel: PlayerStatusPanel = get_status_panel()
	if status_panel.visible:
		status_panel.hide()
	else:
		status_panel.show()


func show_status_panel() -> void:
	get_status_panel().show()


func update_attrs(attrs: Attributes):
	update_with_attrs(attrs)
	
	if get_status_panel().visible:
		get_status_panel().update_attrs(attrs)


func update_status_effects(status: StatusEffects):
	if get_status_panel().visible:
		get_status_panel().update_status_effects(status)

#endregion


func get_player_list() -> Label:
	return player_list


func show_connected_player_info():
	var player_info: String = ""
	if multiplayer.is_server():
		player_info += "You are the host.\n"
	
	player_info += "Player (%s): %s" % [
			multiplayer.get_unique_id(), GameManager.hub.local_client_player_name]
	
	for remote_player_id in multiplayer.get_peers():
		var player_name: String = GameManager.hub.get_remote_player_name(remote_player_id)
		player_info += "\nPlayer (%s): %s" % [
				remote_player_id, player_name]
	
	player_list.text = player_info


func _get_health_bar() -> ResourceBar:
	return find_child("HealthBar")


func _get_mana_bar() -> ResourceBar:
	return find_child("ManaBar")


func _get_exp_bar() -> ResourceBar:
	return find_child("ExpBar")


func update_with_attrs(attrs: Attributes) -> void:
	_get_health_bar().set_amount(attrs.current_hp_snapped(), attrs.max_hp)
	_get_mana_bar().set_amount(attrs.current_mana, attrs.max_mana)
	_get_exp_bar().set_amount(attrs.current_exp, attrs.exp_required_next_level)
