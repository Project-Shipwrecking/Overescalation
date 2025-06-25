class_name LevelManager extends TileMapLayer

var tileset = self.tile_set
var available_pattern_ids : Array

enum LEVELS {
	DEFAULT,
	ONE,
	TWO,
	THREE,
	FOUR,
}
var spawns : Dictionary
@export var curr_map : int

func _ready():
	if multiplayer.is_server():
		all_patterns()
		#Global.players_changed.connect(add_map)
		#Global.game_state_changed.connect(begin_game)
		Global.begin_game.connect(begin_game)

func all_patterns():
	available_pattern_ids = []
	for index in range(tileset.get_patterns_count()):
		available_pattern_ids.append(tileset.get_pattern(index))

func _setup_spawns():
	while len(spawns) < 2:
		await get_tree().process_frame
	var spawn_locations: Array[Vector2i] = get_used_cells_by_id(-1, Vector2(10,8))
	for id in range(len(Global.players)):
		spawns.get_or_add(Global.players[id], Vector2.ZERO)
		spawns.set(str(Global.players[id]), spawn_locations[id])
	print_debug(spawns)

func _spawn_players():
	if spawns == null: return
	var players = get_tree().get_nodes_in_group("Players") 
	for i in range(len(players)):
		if spawns.get(str(players[i].name)) != null:
			var curr = players[i] as PlayerClass
			
			curr.teleport.rpc_id(int(curr.name), map_to_local(spawns.get(str(curr.name))) )
			

func pick_random_map():
	if not multiplayer.is_server(): return
	clear()
	var index = ( randi() % len(available_pattern_ids)-1 ) + 1
	var curr_map = index
	set_map(curr_map)
	set_map.rpc_id(Global.players[1], curr_map)
		
@rpc("any_peer", "call_local")
func set_map(index):
	print("map is %s for player %s" % [index, Global.peer_id])
	clear()
	set_pattern(Vector2i(-12,8), available_pattern_ids[index])
	Global.game_state = Global.GAME_STATE.ARENA
	Global.begin_game.emit(true)

func begin_game(client: bool = false):
	if not multiplayer.is_server() or client: return
	print_debug("spawning, global players: " + str(Global.players))
	pick_random_map()
	_setup_spawns()
	_spawn_players()
	
