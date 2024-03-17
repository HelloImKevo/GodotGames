extends Node
## SoundManager


const CLICK_BUBBLE_POP = preload("res://assets/sound/click_bubble_pop.wav")


func player_hit_sound(audio: AudioStreamPlayer) -> void:
	audio.stream = CLICK_BUBBLE_POP
	audio.play()
