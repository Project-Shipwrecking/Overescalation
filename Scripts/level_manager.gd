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
		Global.game_state_changed.connect(begin_game)
		Global.players_changed.connect(add_map)

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
	set_pattern(Vector2i(-12,8), available_pattern_ids[index])
	var curr_map = index

func add_map(player_id):
	if len(Global.players) == 1:
		pick_random_map()
	elif len(Global.players) > 1:
		set_map.rpc_id(int(Global.players[1]), curr_map)

		
@rpc("any_peer", "call_local")
func set_map(index):
	clear()
	set_pattern(Vector2i(-12,8), available_pattern_ids[index])

func begin_game(new_state:int, old_state:int):
	print_debug("GAME BEGINS, game state is " + str(Global.game_state))
	if not multiplayer.is_server(): return
	if not (new_state == Global.GAME_STATE.ARENA and Global.GAME_STATE.MAIN_MENU):
		_setup_spawns()
		_spawn_players()
	
