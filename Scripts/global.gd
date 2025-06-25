extends Node

signal game_state_changed(state : int, prev_state : int)

var spawn_locs : Dictionary 
var kills : int = 0
var deaths : int = 0

enum GAME_STATE {
	MAIN_MENU,
	ARENA,
	ESCALATE,
	WON,
}
@export var game_state = 0 :
	set(value):
		game_state_changed.emit(value, game_state)
		game_state = value

var players := []

	
func _spawn_players():
	if spawn_locs == null or not multiplayer.is_server():
		players = get_tree().get_nodes_in_group("Players")
		for i in range(len(players)):
			if spawn_locs.get(players[i].name) != null:
				players[i].position = spawn_locs.get(players[i].name)
