@tool
class_name NPC
extends StaticBody2D


enum Type { FIREFIGHTER_MALE, SCIENTIST, AGENT, MEDIC_FEMALE }

@export var npc_type: Type = Type.SCIENTIST

const IDLE_FRAMES: Dictionary = {
	Type.FIREFIGHTER_MALE: [0, 1, 2],
	Type.SCIENTIST: [3, 4, 5],
	Type.AGENT: [48, 49, 50],
	Type.MEDIC_FEMALE: [57, 58, 59]
}

@onready var sprite = $Sprite

var _idle_animation: Tween


func _ready():
	var idle_frames: Array = IDLE_FRAMES[npc_type]
	sprite.frame = idle_frames[0]
	if Engine.is_editor_hint():
		return
	
	_idle_animation = TweenUtils.tween_loop_frames(sprite, idle_frames, 0.3)
