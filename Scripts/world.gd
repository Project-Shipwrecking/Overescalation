extends Node

@onready var main_menu :  Control = $CanvasLayer/Main
@onready var pause_menu :  Control = $CanvasLayer/PauseMenu
@onready var address_in : Control = main_menu.get_node(^"ColorRect/CenterContainer/VBoxContainer/AddressEntry")
@onready var scene_path = "res://Scenes/world.tscn"


const PLAYER = preload("res://Scenes/player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

func _ready():
	Global.game_state = Global.GAME_STATE.MAIN_MENU
	Global.begin_game.connect(_client_begin)

func _unhandled_input(event: InputEvent) -> void:
	match Global.game_state:
		Global.GAME_STATE.MAIN_MENU:
			if Input.is_action_just_pressed("quit"):
				get_tree().quit()
		Global.GAME_STATE.ARENA:
			if Input.is_action_just_pressed("quit"):
				if pause_menu.visible == false: pause_menu.open()
				else: pause_menu.close()
				
		
func _on_host_button_pressed() -> void:
	enet_peer.create_server(PORT, 10)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	
	upnp_setup()
	
	main_menu.show_loading("Waiting for Player #2")

func _on_join_button_pressed() -> void:
	main_menu.show_loading()
	
	var err = enet_peer.create_client(address_in.text, PORT)
	assert(err == OK, "Enet peer failed to create client. Error %s" % err)
	multiplayer.multiplayer_peer = enet_peer
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnect)

func _on_peer_connected(id:int):
	main_menu.show_loading("Connected!", true)
	

func _on_server_disconnect():
	print_debug("server disconnect")
	get_tree().change_scene_to_file(scene_path)
	

func _on_connected_to_server():
	print("✅ Connected to server.")
	main_menu.show_loading("Connected!", false)
	
func _on_connection_failed():
	push_error("❌ Connection to server failed!")
	main_menu.show_loading("Connection failed!")
	await get_tree().create_timer(1)
	main_menu.close()

func player_joined():
	main_menu.close()

func add_player(peer_id):
	
	var player = PLAYER.instantiate()
	player.name = str(peer_id)
	player.mult_id = peer_id
	player.set_multiplayer_authority(peer_id)
	add_child(player)
	
	Global.players.append(peer_id)
	if is_multiplayer_authority(): Global.peer_id = player.name
	Global.players_changed.emit(Global.players)
	
func _client_begin(client : bool = false):
	Global.game_state = Global.GAME_STATE.ARENA
	if client:
		main_menu.close()

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
		Global.players.erase(peer_id)

# Connection over internet is below
func upnp_setup():
	var upnp = UPNP.new()
	
	
	var discover_result = upnp.discover()
	# Check if upnp is good
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, "UPNP Discover failed! Error %s" % discover_result) 
	
	#check if gateway is good
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), "UPNP Invalid Gateway!")
	
	var map_result = upnp.add_port_mapping(PORT)
	# Check port mapping works
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, "UPNP Port Mapping failed! Error %s" % map_result)
	
	print("Success! Have others join this address: %s" % upnp.query_external_address())
