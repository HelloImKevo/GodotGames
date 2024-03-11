class_name PlayerHub
extends Node
## Create one instance per [GameManager] singleton, using [PlayerHub.new].
## The [GameManager] gets created for **each** client, so the local_client_player_name
## should be unique per player.


## Name for my player on the local client.
var local_client_player_name = "The Warrior"


## Names for remote players in id:name format.
## The ID should correspond to each entry in [multiplayer.get_peers].
var players: Dictionary = {}


## Returns remote connected player names only, like "Warrior", "Bandit", "Priest".
func get_remote_player_names() -> Array:
	return players.values()


## Returns the local client player name, plus the names of all connected remote
## player peers.
func get_all_player_names():
	var all_player_names: Array[String] = []
	all_player_names.append(local_client_player_name)
	
	if multiplayer.get_peers() == null:
		## This is a singleplayer game.
		return all_player_names
	
	all_player_names.append_array(get_remote_player_names())
	
	return all_player_names


func get_remote_player_name(remote_player_id: int) -> String:
	if players.has(remote_player_id):
		return players[remote_player_id]
	
	return "Remote Player ID %s Not Found" % [remote_player_id]


## This is more like register_player
func on_player_connected(player_id: int, player_name: String) -> void:
	players[player_id] = player_name
	Logging.mp.info("PlayerHub: on_player_connected -> player_id = %s , player_name = %s" % [
			player_id, player_name])
