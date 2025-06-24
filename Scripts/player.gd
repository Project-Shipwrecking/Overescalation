extends CharacterBody2D
class_name PlayerClass

signal health_changed(health_value : float)

@export var camera : Camera2D
@export var anim_player : AnimationPlayer
@export var raycast : RayCast2D
@export var sprite : Sprite2D
@export var gun : Marker2D
@export_range(1,10,0.5) var SPEED := 300
var ACCELERATION_SPEED = SPEED * 6.0
@export_range (3,20,0.5) var JUMP_VELOCITY := -750.
@export_range (3,20,0.5) var TERMINAL_VELOCITY := 700
@export_range(0.1, 5.0, 0.05) var MOUSE_SENSE := 1
@export_range(5,20, 0.5) var GRAVITY := 2100

var health : float = 3

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if camera == null:
		camera = $Camera2D
	#if anim_player == null:
		#anim_player = $AnimationPlayer
	#if muzzle_flash == null:
		#muzzle_flash = $Camera3D/Pistol/MuzzleFlash
	#if raycast == null:
		#raycast = $Camera3D/RayCast3D
	
	if not is_multiplayer_authority(): return
	
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.make_current()

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	if Input.is_action_just_pressed("shoot"):
		# and anim_player.current_animation != "shoot"
		#_player_shoot_effect.rpc()
		gun.shoot()
		#_update_raycast()
		#if raycast.is_colliding():
			#var hit_player = raycast.get_collider()
			#hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())

func _update_raycast():
	if not is_multiplayer_authority(): return
	# Get the mouse's global position
	var mouse_position = get_global_mouse_position()

	# Calculate the direction from the character to the mouse
	var direction = (mouse_position - global_position).normalized()

	# Set the RayCast2D's target position
	# The end_point is relative to the RayCast2D's local origin.
	# We want it to extend in the 'direction' we calculated, for a certain length.
	# A length of 1000 is usually sufficient for most screen sizes.
	raycast.target_position = direction * 10000

	# Force an update of the raycast (important if you're not moving the raycast node itself)
	raycast.force_raycast_update()

#TODO Improve movement, add crouch, coyote timing, etc to make it smoother
func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if Input.is_action_just_pressed("jump"):
		try_jump()
	elif Input.is_action_just_released("jump") and velocity.y < 0.0:
		# The player let go of jump early, reduce vertical momentum.
		velocity.y *= 0.6
	# Fall.
	velocity.y = minf(TERMINAL_VELOCITY, velocity.y + GRAVITY * delta)

	var direction := Input.get_axis("left", "right") * SPEED
	velocity.x = move_toward(velocity.x, direction, ACCELERATION_SPEED * delta)

	#if not is_zero_approx(velocity.x):
		#if velocity.x > 0.0:
			#sprite.scale.x = 1.0
		#else:
			#sprite.scale.x = -1.0

	#floor_stop_on_slope = not platform_detector.is_colliding()
	
	#if anim_player.current_animation == "shoot":
		#pass
	#elif input_dir != Vector2.ZERO and is_on_floor():
		#anim_player.play("move")
	#else:
		#anim_player.play("idle")
	move_and_slide()

func _process(_delta: float) -> void:
	_update_raycast()

func try_jump() -> void:
	if is_on_floor():
		#jump_sound.pitch_scale = 1.0
	#elif _double_jump_charged:
		#_double_jump_charged = false
		#velocity.x *= 2.5
		#jump_sound.pitch_scale = 1.5
		pass
	else:
		return
	velocity.y = JUMP_VELOCITY
	#jump_sound.play()
	
#@rpc("authority", "call_local")
#func _player_shoot_effect():
	#anim_player.stop()
	#anim_player.play("shoot")
	##TODO Make visual effect fade and make it better and add sound
	#muzzle_flash.restart()
	#muzzle_flash.emitting = true

@rpc("any_peer", "call_local")
func receive_damage():
	health -= 1
	if health == 0:
		health = 3
		position = Vector2.ZERO
	health_changed.emit(health)
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "shoot":
		anim_player.play("idle")
