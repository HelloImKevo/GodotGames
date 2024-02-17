class_name FloatingNumber
extends Node2D


enum Style { NORMAL, CRITICAL, HEALING }

## Text displayed in the floating number label.
@export var display_text: String
## Determines color of text.
@export var style: Style
## How fast the text will drift.
@export var drift_speed: float

@onready var text_label = $TextLabel
@onready var fade_delay_timer = $FadeDelayTimer

## Quick fade animation played before the text is destroyed with [queue_free].
var _fade_away: Tween


func init(text: String, s: Style, speed: float):
	display_text = text
	style = s
	drift_speed = speed


func _ready():
	text_label.text = display_text
	match style:
		Style.NORMAL:
			text_label.self_modulate = Color.WHITE
		Style.CRITICAL:
			text_label.self_modulate = Color.YELLOW
		Style.HEALING:
			text_label.self_modulate = Color.LIME_GREEN


func _process(delta):
	# Drift upwards.
	position.y -= drift_speed * delta
	

## Invoked after the text has been drifting briefly. Then we want the text to
## quickly fade out, and then this entity will be destroyed.
func _on_fade_delay_timer_timeout():
	_fade_away = TweenUtils.tween_fade_away(text_label, 0.3)
	_fade_away.connect("finished", _on_fade_away_finished)


func _on_fade_away_finished() -> void:
	if _fade_away != null:
		_fade_away.kill()
	
	set_process(false)
	queue_free()
