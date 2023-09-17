class_name MoveTowardsMovement
extends EntityMovement

@export var speed_increase_over_distance: Curve
@export var max_distance: float = 512
@export var prediction_distance: float = 16.0
@export var velocity_damp: float = 1.0

var target_position: Vector2

func _physics_process(delta: float) -> void:
	var direction: Vector2 = global_position.direction_to(get_prediction_position())
	
	var distance = clamp(rigidbody.distance_to_player, 0, max_distance)
	var modifier = speed_increase_over_distance.sample(distance / max_distance)
	
	rigidbody.apply_force(direction * delta * rigidbody.linear_damp * current_speed * speed_modifier * 100 * (1.0 + modifier))

func get_prediction_position() -> Vector2:
	
	var prediction_direction = player.velocity.normalized() * (prediction_distance + (player.velocity.length() * velocity_damp))
	
	var player_position = player.global_position
	var final_position = player_position + prediction_direction

	target_position = final_position
	
	return final_position
