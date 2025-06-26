extends RigidBody2D
class_name Bullet

var speed : float = 1000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	print("Bullet with velocity %s" % linear_velocity)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _init(given_speed : float = 1000) -> void:
	speed = given_speed
	top_level = true

func _on_body_entered(body: Node) -> void:
	if body is TileMapLayer or body is Bullet:
		
		queue_free()
	elif body is PlayerClass:
		if not is_multiplayer_authority():
			body.receive_damage.rpc_id(body.get_multiplayer_authority())
		queue_free()
		
