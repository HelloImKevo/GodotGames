class_name ActiveTool
extends Control
## GUI component that shows the current active tool for a player.

## 1-based index. 1 refers to the only player in singleplayer mode.
@export var player_number: int = 1

@onready var sprite: Sprite2D = $Sprite


func _ready():
	GUIManager.cycle_next_tool.connect(cycle_next_tool)


## player_num: 0-based index. 0 refers to the only player in singleplayer mode.
func cycle_next_tool(__player_number: int) -> void:
	print("cycle_next_tool : %s , %s" % [player_number, __player_number])
	
	if not __player_number == player_number:
		return
	
	# TODO: For testing purposes only. This won't work once the frames wrap.
	sprite.frame = sprite.frame + 1
