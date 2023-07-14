class_name PlayerTrackingMovement
extends PathfindingMovement

@export var speed_increase_over_distance: Curve
@export var max_distance = 256

func _process(delta: float) -> void:
	super._process(delta)
	var distance = clamp(agent.distance_to_target(), 0, max_distance)
	var modifier = speed_increase_over_distance.sample(distance / max_distance)
	current_speed = move_speed * modifier

func update_path() -> void:
	target_position = player.global_position
	super.update_path()
