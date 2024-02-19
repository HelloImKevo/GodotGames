class_name TinyCoins
extends Area2D


var _time_alive: float = 0.0


func _ready():
	$Sound.play()


func _process(delta):
	_time_alive += delta
