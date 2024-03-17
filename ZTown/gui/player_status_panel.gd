class_name PlayerStatusPanel
extends Control


@onready var title = $PanelContainer/MC/VBoxStack/HBoxContainer/Title

@onready var level_label = $PanelContainer/MC/VBoxStack/HB/LevelLabel
@onready var _exp = $PanelContainer/MC/VBoxStack/HB/Exp
@onready var hp_label = $PanelContainer/MC/VBoxStack/HB2/HPLabel
@onready var hp_regen_label = $PanelContainer/MC/VBoxStack/HB2/HPRegenLabel

@onready var mana_label = $PanelContainer/MC/VBoxStack/HB4/ManaLabel
@onready var mana_regen_label = $PanelContainer/MC/VBoxStack/HB4/ManaRegenLabel

@onready var attack_label = $PanelContainer/MC/VBoxStack/HB5/AttackLabel
@onready var status_label = $PanelContainer/MC/VBoxStack/HB6/StatusLabel


func _ready():
	title.text = GameManager.hub.local_client_player_name


func update_attrs(attrs: Attributes) -> void:
	level_label.text = str(attrs.level())
	_exp.text = "%s / %s xp" % [attrs.stat(Attributes.CURRENT_EXP), attrs.stat(Attributes.EXP_REQUIRED_NEXT_LEVEL)]
	hp_label.text = "%.0f / %.0f" % [attrs.current_hp(), attrs.max_hp()]
	hp_regen_label.text = "+%.1f / s" % attrs.stat(Attributes.HP_REGEN)
	mana_label.text = "%.0f / %.0f" % [attrs.current_mana(), attrs.stat(Attributes.MAX_MANA)]
	mana_regen_label.text = "+%.1f / s" % attrs.stat(Attributes.MANA_REGEN)
	attack_label.text = "%.0f - %.0f" % [attrs.raw_attack_min(), attrs.raw_attack_max()]


func update_status_effects(status: StatusEffects) -> void:
	if status.is_burning():
		status_label.text = "Burning"
	else:
		status_label.text = "Normal"
