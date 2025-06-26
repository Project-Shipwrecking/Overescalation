extends Node

signal game_state_changed(state : int, prev_state : int)
signal players_changed(players : Array)
signal begin_game()
signal player_died(player : PlayerClass)

var spawn_locs : Dictionary 
var kills : int = 0
var deaths : int = 0
var peer_id : int = -1

enum GAME_STATE {
	MAIN_MENU,
	ARENA,
	ESCALATE,
	WON,
}
@export var game_state = 0 :
	set(value):
		if game_state != value:
			game_state_changed.emit(value, game_state)
			game_state = value

var players := [] :
	set(value):
		players_changed.emit(value)
		players = value
	
