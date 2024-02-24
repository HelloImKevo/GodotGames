class_name EngineUtils


## Prevents jittery UI labels and optimizes game performance.
static func ui_update_interval():
	return Engine.get_physics_frames() % 4 == 0
