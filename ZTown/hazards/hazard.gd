class_name Hazard
extends Area2D


@onready var status_effect: StatusEffect = $StatusEffect


## Returns the status effect for when the Area is entered by another body.
func get_area_entered_status_effect() -> StatusEffect:
	return status_effect
