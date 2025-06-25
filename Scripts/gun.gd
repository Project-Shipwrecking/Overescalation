class_name Gun extends Marker2D

const BULLET_SCENE = preload("res://Scenes/bullet.tscn")

#@onready var sound_shoot := $Shoot as AudioStreamPlayer2D
@onready var timer := $Cooldown as Timer
@onready var sprite := $GunSprite as Sprite2D
@onready var mag := $Magazine as Magazine
@onready var spawner := $MultiplayerSpawner as MultiplayerSpawner

func _unhandled_input(event: InputEvent) -> void:
	
## For debugging magazine
	#if event.is_action_pressed("jump"):
		#mag.reload()
	#elif event.is_action_pressed("right"):
		#mag.use_bullet()
	#elif event.is_action_pressed("down"):
		#mag.update_mag_size(mag.get_mag_size() + 1)
	#elif event.is_action_pressed("left"):
		#mag.update_mag_size(mag.get_mag_size() - 1)
	if event.is_action_pressed("reload"):
		reload()
	
func reload(skip_animation : bool = false):
	mag.reload(skip_animation)

func update_rel_pos(player_pos : Vector2):
	if not is_multiplayer_authority(): return
	
	var direction = (get_global_mouse_position() - player_pos).normalized()
	rotation = direction.angle()
	position = direction * 40
	sprite.rotation = get_angle_to(get_global_mouse_position())
	if position.x < 0:
		sprite.flip_v = true
		mag.flip_magazine(true)
	else: 
		sprite.flip_v = false
		mag.flip_magazine(false)
		
	return direction

# This method is only called by Player.gd.

@rpc("reliable", "call_local")
func _request_shoot(start_position: Vector2, shoot_direction: Vector2, extra_velocity: Vector2):
	_spawn_bullet.rpc_id(0, start_position, shoot_direction, extra_velocity) 

@rpc("any_peer", "reliable", "call_local")
func _spawn_bullet(start_position, shoot_direction, extra_vel):
	var bullet_instance = BULLET_SCENE.instantiate()
	get_tree().current_scene.add_child(bullet_instance)
	
	bullet_instance.global_position = start_position + extra_vel/100
	# Assuming your bullet script has a method to set its direction/velocity
	bullet_instance.linear_velocity = shoot_direction * bullet_instance.speed + extra_vel

func shoot(player_pos : Vector2 = Vector2.ZERO, extra_velocity : Vector2 = Vector2.ZERO) -> bool:
	if not timer.is_stopped() or mag.use_bullet() == false:
		return false
	var direction = update_rel_pos(player_pos)
	
	_request_shoot(get_global_position(), direction, extra_velocity)

	
	#sound_shoot.play()
	timer.start()
	return true
