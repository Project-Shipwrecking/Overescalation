extends Node

signal game_state_changed(state : int)

var kills : int = 0
var deaths : int = 0

enum GAME_STATE {
	MAIN_MENU,
	ARENA,
	ESCALATE,
	WON,
}
var game_state = 0 :
	set(value):
		game_state_changed.emit(value)
		game_state = value

var players := []
