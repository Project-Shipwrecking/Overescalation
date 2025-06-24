class_name Gun extends Marker2D

const BULLET_SCENE = preload("res://Scenes/bullet.tscn")

#@onready var sound_shoot := $Shoot as AudioStreamPlayer2D
@onready var timer := $Cooldown as Timer
@onready var sprite := $GunSprite as Sprite2D
@onready var mag := $Magazine as Magazine

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
		mag.reload()
	

func update_rel_pos(player_pos : Vector2):
	if not is_multiplayer_authority(): return
	
	var direction = (get_global_mouse_position() - player_pos).normalized()
	rotation = direction.angle()
	position = direction * 40
	sprite.rotation = get_angle_to(get_global_mouse_position())
	mag.rotation_degrees = sprite.rotation_degrees
	mag.position = sprite.position
	if position.x < 0:
		sprite.flip_v = true
	else: 
		sprite.flip_v = false
		
	return direction

# This method is only called by Player.gd.

@rpc("reliable", "call_remote")
func _request_shoot(start_position: Vector2, shoot_direction: Vector2):
	# This code only runs on the server (authority)

	# Safety check: Is the server the authority for this player?
	# In a typical setup, the server has authority over all players.
	# If clients could also be authorities, you'd need more nuanced checks.

	# Now, tell all other peers (including the client who requested it) to spawn the bullet
	# Using "call_others" ensures the server itself doesn't re-spawn if it just spawned it locally.
	# If the server is also a "player" on the screen, use "call_rpc" with "any_peer"
	#_spawn_bullet.rpc(start_position, shoot_direction)
	_spawn_bullet.rpc_id(0, start_position, shoot_direction) # Call RPC on all clients (peer_id 0 is the server)

@rpc("any_peer", "reliable", "call_local")
func _spawn_bullet(start_position, shoot_direction):
	var bullet_instance = BULLET_SCENE.instantiate()
	get_tree().current_scene.add_child(bullet_instance)
	
	bullet_instance.global_position = start_position
	# Assuming your bullet script has a method to set its direction/velocity
	bullet_instance.linear_velocity = shoot_direction * bullet_instance.speed
	print("direction is" + str(shoot_direction) )

func shoot(player_pos : Vector2 = Vector2.ZERO) -> bool:
	if not timer.is_stopped() or mag.use_bullet() == false:
		return false
	var direction = update_rel_pos(player_pos)
	
	_request_shoot(get_global_position(), direction)

	
	#sound_shoot.play()
	timer.start()
	return true
