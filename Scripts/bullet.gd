extends RigidBody2D
class_name Bullet

var speed : float = 850

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _init(given_speed : float = 850) -> void:
	speed = given_speed
	top_level = true

func _on_body_entered(body: Node) -> void:

	
	if body is PlayerClass:
		if not is_multiplayer_authority():
			body.receive_damage.rpc_id(body.get_multiplayer_authority())
		queue_free()
	elif body is TileMapLayer:
		queue_free()
	elif body is Bullet:
		body.queue_free()
		queue_free()
		
