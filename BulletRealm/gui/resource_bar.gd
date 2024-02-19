@tool
class_name ResourceBar
extends TextureProgressBar
## ResourceBar : A health or mana bar that can be associated with a Player or an Enemy.


## TODO: Another solution to the "Rotating Health Bar" problem is to make this
## have a Node2D parent, and then reference the @onready texture_progress_bar
## and programmatically update that way. Then, the parent global_rotation could
## be fixed to 0.

enum Style { HEALTH, MANA, EXPERIENCE }

## Signal fired when the resource bar is empty. If the Health is empty, this
## could mean that the unit is dead.
signal empty

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
	max_value = start_amount
	value = start_amount
	_apply_style_color()


func _apply_style_color() -> void:
	match (style):
		Style.HEALTH:
			tint_progress = Color.FIREBRICK
		Style.MANA:
			tint_progress = Color.ROYAL_BLUE
		Style.EXPERIENCE:
			tint_progress = Color.YELLOW


## Legacy functionality - no longer used.
func set_color() -> void:
	#if fixed_color != Color.BLACK:
		##print("color is not black")
		#tint_progress = fixed_color
		#return
	if value < level_low:
		tint_progress = COLOR_DANGER
	elif value < level_med:
		tint_progress = COLOR_MIDDLE
	else:
		tint_progress = COLOR_GOOD


func set_amount(amount) -> void:
	value = snapped(amount, 1)


## Updates the resource bar value, by a positive or negative amount.
func update_value(v: int) -> void:
	value += v
	if value <= 0:
		empty.emit()


## Reduces the resource bar by the specified amount (which should be positive).
func take_damage(v: int) -> void:
	update_value(-(abs(v)))


func heal(v: int) -> void:
	update_value(abs(v))


func restore_mana(v: int) -> void:
	update_value(abs(v))
