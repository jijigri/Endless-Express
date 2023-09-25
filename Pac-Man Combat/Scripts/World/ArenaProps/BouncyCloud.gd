extends RigidBody2D

@onready var initial_position: Vector2 = global_position

var time: float

func _physics_process(delta: float) -> void:
	if global_position.distance_squared_to(initial_position) > 2.0:
		var dir = global_position.direction_to(initial_position)
		dir.x = 0
		dir = dir.normalized()
		apply_force(dir * 500.0)
	pass

func _on_player_detection_body_entered(body: Node2D) -> void:
	
	if !body is Player:
		return
	
	if body.velocity.y < 0:
		return

	apply_impulse(Vector2.DOWN * 32.0 * linear_damp)


func _on_player_detection_body_exited(body: Node2D) -> void:
	
	if !body is Player:
		return
	
	var dist = global_position.distance_to(initial_position)
	apply_impulse(Vector2.UP * 32.0 * linear_damp)
	
	print_debug(dist)
	var vel = 620.0
	if dist > 9.0:
		vel = 800.0
	
	if Input.is_action_pressed("move_down") || Input.is_action_pressed("interact_cancel"):
		return
	
	body.velocity = Vector2(body.velocity.x, -vel)
