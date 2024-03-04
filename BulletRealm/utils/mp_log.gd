extends LogStream


## Singleton used for Multiplayer logging.
## NOTE: This is a client-side singleton - it will get initialized once for each player.


func _init():
	super("Multiplayer", LogLevel.DEFAULT)


func debug(message: String, values = {}):
	var msg: String = "Client [%s] --> %s\n" % [_mp_api().get_unique_id(), message]
	call_thread_safe("_internal_log", msg, values, LogLevel.DEBUG)


func info(message: String, values = {}):
	var msg: String = "Client [%s] --> %s\n" % [_mp_api().get_unique_id(), message]
	call_thread_safe("_internal_log", msg, values, LogLevel.INFO)


func _mp_api():
	var main_scene_tree = Engine.get_main_loop() as SceneTree
	return main_scene_tree.get_multiplayer()
