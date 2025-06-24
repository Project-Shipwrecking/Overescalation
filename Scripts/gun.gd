class_name Gun extends Marker2D

const BULLET_VELOCITY = 850.0
const BULLET_SCENE = preload("res://Scenes/bullet.tscn")

#@onready var sound_shoot := $Shoot as AudioStreamPlayer2D
@onready var timer := $Cooldown as Timer
@onready var sprite := $GunSprite as Sprite2D

func update_rel_pos(player_pos : Vector2):
	var direction = (get_global_mouse_position() - player_pos).normalized()
	position = direction * 40
	sprite.rotation = get_angle_to(get_global_mouse_position())
	if position.x < 0:
		sprite.flip_v = true
	else: 
		sprite.flip_v = false
		
	return direction

# This method is only called by Player.gd.
func shoot(player_pos : Vector2 = Vector2.ZERO) -> bool:
	var direction = update_rel_pos(player_pos)
	if not timer.is_stopped():
		return false
	var bullet := BULLET_SCENE.instantiate() as Bullet
	bullet.global_position = global_position
	bullet.linear_velocity = direction * BULLET_VELOCITY

	bullet.set_as_top_level(true)
	add_child(bullet)
	#sound_shoot.play()
	timer.start()
	return true
