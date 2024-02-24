@tool
class_name ResourceBar
extends Control
## ResourceBar : A health or mana bar that can be associated with a Player or an Enemy.


## TODO: Another solution to the "Rotating Health Bar" problem is to make this
## have a Node2D parent, and then reference the @onready texture_progress_bar
## and programmatically update that way. Then, the parent global_rotation could
## be fixed to 0.

enum Style { HEALTH, MANA, EXPERIENCE }

## Signal fired when the resource bar is empty. If the Health is empty, this
## could mean that the unit is dead.
signal empty

@export var text_label: Label
@export var progress_bar: TextureProgressBar
@export var style: Style = Style.HEALTH

## Threshold when the resource bar will change to a warning color.
@export var level_low: int = 30
## Threshold when the resource bar will change color to indicate medium level.
@export var level_med: int = 65
## Starting resource amount, like HP or Mana.
@export var start_amount: int = 100

const COLOR_DANGER: Color = Color("#cc0000")
const COLOR_MIDDLE: Color = Color("#ff9900")
const COLOR_GOOD: Color = Color("#33cc33")


func _ready():
	progress_bar.max_value = start_amount
	progress_bar.value = start_amount
	_apply_style_color()


func _apply_style_color() -> void:
	match (style):
		Style.HEALTH:
			progress_bar.tint_progress = Color.FIREBRICK
		Style.MANA:
			progress_bar.tint_progress = Color.ROYAL_BLUE
		Style.EXPERIENCE:
			progress_bar.tint_progress = Color.YELLOW


func set_amount(current, max) -> void:
	progress_bar.max_value = snapped(max, 1)
	progress_bar.value = snapped(current, 1)
	_update_text_label()


## Updates the resource bar value, by a positive or negative amount.
func update_value(v: int) -> void:
	progress_bar.value += v
	_update_text_label()
	if progress_bar.value <= 0:
		empty.emit()


## Reduces the resource bar by the specified amount (which should be positive).
func take_damage(v: int) -> void:
	update_value(-(abs(v)))


func heal(v: int) -> void:
	update_value(abs(v))


func restore_mana(v: int) -> void:
	update_value(abs(v))


func _update_text_label() -> void:
	if not text_label:
		return
	
	var first: String = TextUtils.format_val_medium(1, progress_bar.value)
	var second: String = TextUtils.format_val_medium(1, progress_bar.max_value)
	text_label.text = "%s / %s" % [first, second]
