extends CharacterBody3D

signal health_changed(health_value : float)

@export var camera : Camera3D
@export var anim_player : AnimationPlayer
@export var muzzle_flash : GPUParticles3D
@export var raycast : RayCast3D
@export_range(1,10,0.5) var SPEED := 10.
@export_range (3,6,0.5) var JUMP_VELOCITY := 10.
@export_range(0.1, 5.0, 0.05) var MOUSE_SENSE := 1
@export_range(5,20, 0.5) var GRAVITY := 20

var health : float = 3

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if camera == null:
		camera = $Camera3D
	if anim_player == null:
		anim_player = $AnimationPlayer
	if muzzle_flash == null:
		muzzle_flash = $Camera3D/Pistol/MuzzleFlash
	if raycast == null:
		raycast = $Camera3D/RayCast3D
	
	if not is_multiplayer_authority(): return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005 * MOUSE_SENSE)
		camera.rotate_x(-event.relative.y * 0.005 * MOUSE_SENSE)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	if Input.is_action_just_pressed("shoot") and anim_player.current_animation != "shoot":
		_player_shoot_effect.rpc()
		if raycast.is_colliding():
			var hit_player = raycast.get_collider()
			hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())

#TODO Improve movement, add crouch, coyote timing, etc to make it smoother
func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		#velocity += get_gravity() * delta
		#TODO Fix gravity
		velocity += Vector3(0,-GRAVITY,0) * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if anim_player.current_animation == "shoot":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		anim_player.play("move")
	else:
		anim_player.play("idle")
	move_and_slide()

@rpc("authority", "call_local")
func _player_shoot_effect():
	anim_player.stop()
	anim_player.play("shoot")
	#TODO Make visual effect fade and make it better and add sound
	muzzle_flash.restart()
	muzzle_flash.emitting = true

@rpc("any_peer", "call_local")
func receive_damage():
	health -= 1
	if health == 0:
		health = 3
		position = Vector3.ZERO
	health_changed.emit(health)
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "shoot":
		anim_player.play("idle")
