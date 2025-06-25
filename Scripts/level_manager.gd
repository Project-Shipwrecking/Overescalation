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

func _ready():
	all_patterns()

func all_patterns():
	available_pattern_ids = []
	for index in range(tileset.get_patterns_count()):
		available_pattern_ids.append(tileset.get_pattern(index))
