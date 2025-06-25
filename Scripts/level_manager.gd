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

func _ready():
	if multiplayer.is_server():
		all_patterns()
		Global.game_state_changed.connect(begin_game)

func all_patterns():
	available_pattern_ids = []
	for index in range(tileset.get_patterns_count()):
		available_pattern_ids.append(tileset.get_pattern(index))

func _setup_spawns():
	var spawn_locations: Array[Vector2i] = get_used_cells_by_id(-1, Vector2(10,8))
	for id in range(len(Global.players)):
		spawns.get_or_add(Global.players[id], Vector2.ZERO)
		spawns.set(str(Global.players[id]), spawn_locations[id])
	Global.spawn_locs = spawns
	
func get_spawn_location(player_id) -> Vector2:
	return spawns.get(str(player_id))

func _pick_random_map():
	pass

func begin_game(new_state:int, old_state:int):
	print("BEGINNING")
	if not (new_state == Global.GAME_STATE.ARENA and Global.GAME_STATE.MAIN_MENU):
		_pick_random_map()
		_setup_spawns()
	
