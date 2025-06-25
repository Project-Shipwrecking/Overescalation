extends Control

@onready var main_cont := $ColorRect/CenterContainer as CenterContainer
@onready var loading_cont := $ColorRect/CenterContainer2 as CenterContainer
@onready var loading_text := loading_cont.get_node(^"VBoxContainer/Connecting")
var fade_out_duration = 0.2

func _ready():
	reset()



func show_loading(text : String = "Connecting..."):
	main_cont.hide()
	loading_cont.show()
	loading_text.text = text
	

func close() -> void:
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
