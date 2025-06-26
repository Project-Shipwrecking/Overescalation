class_name Magazine extends Control

enum OFFSET {
	DOWN = -19,
	UP = 43,
}

@onready var bullet_icon = preload("res://Scenes/bullet_icon.tscn")
@export var curr_bullets = 8 :
	set(value):
		if value > get_child_count():
			for i in range(value - get_child_count()):
				var icon_instance = bullet_icon.instantiate()
				add_child(icon_instance)
		elif get_child_count() > value:
			for i in range(get_child_count() - value):
				get_child(0).queue_free()
		curr_bullets = value
@export var magazine_max = 8 :
	set(value):
		_recalculate_layout(value)
		magazine_max = value
		curr_bullets = value
var row_len = 4

func _ready() -> void:
	magazine_max = 8

func flip_magazine(up : bool):
	if up:
		position.y = OFFSET.UP
	else:
		position.y = OFFSET.DOWN

func get_mag_size():
	return magazine_max

func _recalculate_layout(new_mag_size : int):
	if get_mag_size() / self.columns >= 5:
		self.columns += 1


func use_bullet() -> bool:
	if curr_bullets > 0:
		curr_bullets -= 1
		return true
	return false
	
func reload(skip_animation : bool = false):
	if skip_animation:
		curr_bullets = magazine_max
	else: #todo add animatin here
		curr_bullets = magazine_max
