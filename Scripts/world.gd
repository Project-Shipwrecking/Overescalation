extends Node


@onready var main_menu :  Control = $"CanvasLayer/Main Menu"
@onready var address_in : Control = $"CanvasLayer/Main Menu/VBoxContainer/AddressEntry"
@export var hud : Control
@export var health_bar : ProgressBar

const PLAYER = preload("res://Scenes/player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

func _ready() -> void:
	if hud == null:
		hud = $CanvasLayer/HUD
	if health_bar == null:
		health_bar = $CanvasLayer/HUD/HealthBar

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
func _on_host_button_pressed() -> void:
	main_menu.hide()
	hud.show()
	
	enet_peer.create_server(PORT, 10)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	
	upnp_setup()

func _on_join_button_pressed() -> void:
	main_menu.hide()
	hud.show()
	
	var err = enet_peer.create_client(address_in.text, PORT)
	assert(err == OK, "Enet peer failed to create client. Error %s" % err)
	multiplayer.multiplayer_peer = enet_peer
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)

func _on_connected_to_server():
	print("✅ Connected to server.")
	# Request server to spawn the player if needed (see note below)

func _on_connection_failed():
	push_error("❌ Connection to server failed!")

func add_player(peer_id):
	var player = PLAYER.instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	add_child(player)
	if player.is_multiplayer_authority():
		player.health_changed.connect(_update_health_bar)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func _update_health_bar(health : float):
	health_bar.value = health

func _on_multiplayer_spawner_spawned(node: Node) -> void:
	if node.is_multiplayer_authority():
		node.health_changed.connect(_update_health_bar)

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
