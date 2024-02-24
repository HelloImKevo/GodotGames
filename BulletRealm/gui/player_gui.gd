class_name PlayerGUI
extends CanvasLayer


@onready var player_status_panel: PlayerStatusPanel = $PlayerStatusPanel


func get_status_panel() -> PlayerStatusPanel:
	return player_status_panel


func _get_health_bar() -> ResourceBar:
	return find_child("HealthBar")


func _get_mana_bar() -> ResourceBar:
	return find_child("ManaBar")


func _get_exp_bar() -> ResourceBar:
	return find_child("ExpBar")


func update_with_attrs(attrs: Attributes) -> void:
	_get_health_bar().set_amount(attrs.current_hp(), attrs.max_hp())
	_get_mana_bar().set_amount(attrs.current_mana(), attrs.max_mana())
	_get_exp_bar().set_amount(attrs.current_exp(), attrs.exp_required_next_level())
