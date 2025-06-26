extends CharacterBody2D
class_name PlayerClass

signal health_changed(health_value : float)

@onready var camera = $Camera2D as Camera2D
#@onready var anim_player = $AnimationPlayer as AnimationPlayer
@onready var raycast = $RayCast2D as RayCast2D
@onready var sprite = $PlayerSprite as Sprite2D 
@onready var gun = $PlayerSprite/Gun as Gun 
@onready var health_bar = $TextureRect/HealthBar as ProgressBar

@export_range(1,10,0.5) var SPEED := 300
var ACCELERATION_SPEED = SPEED * 6.0
@export_range (3,20,0.5) var JUMP_VELOCITY := -750.
@export_range (3,20,0.5) var TERMINAL_VELOCITY := 700
@export_range(0.1, 5.0, 0.05) var MOUSE_SENSE := 1
@export_range(5,20, 0.5) var GRAVITY := 2100

@export var health : float = 3
var num_jumps : int = 1

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	camera.make_current()

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	if Input.is_action_just_pressed("shoot"):
		# and anim_player.current_animation != "shoot"
		#_player_shoot_effect.rpc()
		gun.shoot(global_position)

func _process(_delta: float) -> void:
	gun.update_rel_pos(global_position)
	
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

	if not is_zero_approx(velocity.x):
		if velocity.x > 0.0:
			sprite.flip_h = false
		else:
			sprite.flip_h = true

	#floor_stop_on_slope = not platform_detector.is_colliding()
	
	#if anim_player.current_animation == "shoot":
		#pass
	#elif input_dir != Vector2.ZERO and is_on_floor():
		#anim_player.play("move")
	#else:
		#anim_player.play("idle")
	move_and_slide()
	_handle_collisions()

func _handle_collisions():
	var cols = get_slide_collision_count()
	var col_bodies = []
	for i in range(cols):
		#col_bodies.append(get_slide_collision(i).get_collider())
		var collision : KinematicCollision2D = get_slide_collision(i)
		var body = collision.get_collider()
		if body is TileMapLayer and num_jumps < 1:
			var normal = collision.get_normal()
			if abs(normal.normalized().angle_to(Vector2.UP)) <= PI/2 + 0.1:
				num_jumps = 1
func try_jump() -> void:
	if is_on_floor() or num_jumps > 0:
		#jump_sound.pitch_scale = 1.0
	#elif _double_jump_charged:
		#_double_jump_charged = false
		#velocity.x *= 2.5
		#jump_sound.pitch_scale = 1.5
		pass
	else:
		return
	velocity.y = JUMP_VELOCITY
	if get_slide_collision_count() > 0:
		velocity.x += get_last_slide_collision().get_normal().x * 200
	num_jumps -= 1
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
	health_bar.value = health
	health_changed.emit(health)
	

#func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#if anim_name == "shoot":
		#anim_player.play("idle")
