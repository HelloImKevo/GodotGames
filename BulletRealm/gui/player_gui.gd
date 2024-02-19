class_name PlayerGUI
extends CanvasLayer


@onready var player_status_panel: PlayerStatusPanel = $PlayerStatusPanel

@onready var health_bar = $MC/ResourceBars/MC/VB/HealthBar
@onready var mana_bar = $MC/ResourceBars/MC/VB/ManaBar
@onready var exp_bar = $MC/ResourceBars/MC/VB/ExpBar


func get_status_panel() -> PlayerStatusPanel:
	return player_status_panel


func update_resources(health, mana, xp: int, xp_required_next_level: int) -> void:
	health_bar.set_amount(health)
	mana_bar.set_amount(mana)
	exp_bar.max_value = xp_required_next_level
	exp_bar.set_amount(xp)
