class_name BulletSpriteData


var frame: int
var rotation_degrees: float
var scale: float
var flip_h: bool = false


func _init(f: int, r: float, s: float, flip: bool = false):
	frame = f
	rotation_degrees = r
	scale = s
	flip_h = flip
