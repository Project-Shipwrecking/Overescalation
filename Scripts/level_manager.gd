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
		Global.begin_game.connect(begin_game)
		Global.player_died.connect(next_round)

func all_patterns():
	available_pattern_ids = []
	for index in range(tileset.get_patterns_count()):
		available_pattern_ids.append(tileset.get_pattern(index))

func _setup_spawns():
	if not multiplayer.is_server(): return
	var spawn_locations: Array[Vector2i] = get_used_cells_by_id(-1, Vector2(10,8))
	while (len(spawn_locations) < 2): 
		pick_random_map()
		print_debug(curr_map)
		spawn_locations = get_used_cells_by_id(-1, Vector2(10,8))
	for id in range(len(Global.players)):
		spawns.get_or_add(Global.players[id], Vector2.ZERO)
		spawns.set(str(Global.players[id]), spawn_locations[id])

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
	clear()
	set_pattern(Vector2i(-12,8), available_pattern_ids[index])
	Global.game_state = Global.GAME_STATE.ARENA
	Global.begin_game.emit(true)

func begin_game(client: bool = false):
	if not multiplayer.is_server() or client: return
	pick_random_map()
	await get_tree().process_frame
	_setup_spawns()
	_spawn_players()
	
@rpc("any_peer", "call_local")
func next_round():
	print_debug(get_tree().get_nodes_in_group("Players"))
	if not multiplayer.is_server(): 
		print('bruh')
		next_round.rpc_id(1)
		return
	for play in get_tree().get_nodes_in_group("Players"):
		play.reset.rpc_id(int(play.name))
		print("resetting %s" % play.name)
		
	pick_random_map()
	_setup_spawns()
	_spawn_players()
	
