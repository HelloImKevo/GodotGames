class_name MultiplayerConfigController
extends Control
## To test this, go to Debug > Run Multiple Instances > Run 2 Instances.
## This class is no longer needed. Retaining for educational purposes.
## See snippets about peer.host.compress.

## Work In Progress for tutorial:
## Basics Of Multiplayer In Godot 4! by FinePointCGI

@export var address: String = "127.0.0.1"
@export var port: int = 8910

var peer


func _ready():
	multiplayer.connected_to_server.connect(connected_to_server)


func _process(delta):
	pass


# Called only from clients.
func connected_to_server():
	Log.info("Connected to Server!")
	send_player_information.rpc_id(1, $LineEdit.text, multiplayer.get_unique_id())


@rpc("any_peer")
func send_player_information(name, id):
	var players: Dictionary = {}
	
	#if multiplayer.is_server():
		#for i in players:
			#send_player_information.rpc(players[i].name, i)


func _on_btn_host_pressed():
	peer = ENetMultiplayerPeer.new()
	var max_clients = 2
	var error = peer.create_server(port, max_clients)
	if error != OK:
		Log.warn("Cannot host: " + error)
		return
	
	# Can use a different compression format for local co-op / LAN, versus online connection.
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	Log.info("Waiting for Players!")
	send_player_information($LineEdit.text, multiplayer.get_unique_id())


func _on_btn_join_pressed():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	# The compression *must be consistent* across the board.
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
