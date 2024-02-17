class_name UnitLabel
extends Node2D

@onready var level_label = $LevelLabel
@onready var name_label = $NameLabel


# TODO: Derive the unit's name from the parent node?
func set_name_and_level(unit_name: String, level: int) -> void:
	name_label.text = unit_name
	# TODO: This needs to be updated when a unit levels up (might not be relevant
	# to enemy units).
	level_label.text = str(level)


func update_level(level: int) -> void:
	level_label.text = str(level)
