extends Control

@onready var main_cont := $ColorRect/CenterContainer as CenterContainer
@onready var loading_cont := $ColorRect/CenterContainer2 as CenterContainer
@onready var loading_text := loading_cont.get_node(^"VBoxContainer/Connecting") as RichTextLabel
@onready var begin := loading_cont.get_node(^"VBoxContainer/BeginButton") as Button
var fade_out_duration = 0.2

func _ready():
	reset()

func show_loading(text : String = "Connecting...", begin_button : bool = false):
	if begin.visible: return
	main_cont.hide()
	loading_cont.show()
	loading_text.text = text
	if begin_button:
		begin.show()
	elif not multiplayer.is_server():
		loading_text.text += "\nWaiting for host to begin..."
	

func close() -> void:
	begin.hide()
	
	var tween := create_tween()
	get_tree().paused = false
	tween.tween_property(
		self,
		^"modulate:a",
		0.0,
		fade_out_duration
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(
		loading_cont,
		^"anchor_bottom",
		0.5,
		fade_out_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(hide)

func reset():
	main_cont.show()
	loading_cont.hide()
	begin.hide()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_begin_button_pressed() -> void:
	Global.begin_game.emit()
	close()
