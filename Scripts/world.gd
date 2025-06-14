extends Node

@onready var main_menu :  Control= $"CanvasLayer/Main Menu"

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
func _on_host_button_pressed() -> void:
	pass # Replace with function body.

func _on_join_button_pressed() -> void:
	pass # Replace with function body.
