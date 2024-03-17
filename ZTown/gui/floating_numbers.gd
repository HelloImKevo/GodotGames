class_name FloatingNumbers
extends Node2D


# TODO: I added the 'FloatingNumber' child to the scene just for IDE editor
# purposes - it might hurt game performance and should be removed later.

const FLOATING_TEXT: PackedScene = preload("res://gui/floating_number.tscn")


func create_floating_number(value: float, style: FloatingNumber.Style = FloatingNumber.Style.NORMAL):
	# TODO: Consider a scaling effect based on the amount of numbers being shown,
	# so as a player attacks faster, the numbers fade more quickly.
	var floating_text: FloatingNumber = FLOATING_TEXT.instantiate()
	floating_text.init(TextUtils.format_val_medium(1, value), style, 50.0)
	add_child(floating_text)


## Used for development purposes.
func create_random_number() -> void:
	var rand_dmg = randf_range(50.0, 50000.0)
	var style: FloatingNumber.Style = FloatingNumber.Style.values().pick_random()
	self.create_floating_number(rand_dmg, style)
