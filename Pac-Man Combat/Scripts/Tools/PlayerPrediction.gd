class_name PlayerPrediction
extends Node2D

@export var tracks_player_when_not_moving: bool = true
@export var min_predict_distance_in_tiles: int = 24
@export var max_predict_distance_in_tiles: int = 999
@export_range(0.1, 20.0, 0.5) var player_velocity_damp = 5.0

@onready var debug_line: Line2D = $DebugLine
@onready var player = get_tree().get_first_node_in_group("Player")

var last_player_velocity: Vector2 = Vector2()

func _process(_delta: float) -> void:
	get_player_velocity()

func get_player_velocity() -> void:
	if player.velocity.length_squared() > 40000:
		last_player_velocity = player.velocity
		if player.is_wall_sliding:
			last_player_velocity.x = 0
		else:
			last_player_velocity.y = player.velocity.y / 15

func get_prediction_position() -> Vector2:
	
	var prediction_direction = last_player_velocity.normalized()
	#var distance_remaining = 16 * predict_distance_in_tiles
	var distance_remaining = clamp(
		player.velocity.length() / player_velocity_damp,
		min_predict_distance_in_tiles * 16,
		max_predict_distance_in_tiles * 16
		)
	
	if tracks_player_when_not_moving:
		if player.velocity.length() < 50:
			distance_remaining *= 0
	
	var cast_position = player.global_position
	
	var space_state = get_world_2d().direct_space_state
	
	var end_pos = player.global_position + prediction_direction
	
	debug_line.clear_points()
	debug_line.add_point(player.global_position - global_position, 0)
	
	var error = 1
	while distance_remaining > 0:
		var query = PhysicsRayQueryParameters2D.create(
		cast_position, cast_position + (prediction_direction * distance_remaining), 4, [self]
		)
		var result = space_state.intersect_ray(query)
		
		if result.size() > 0:
			#Hit a solid object
			var hit_position_corrected: Vector2 = result.position - (prediction_direction * 16)
			
			distance_remaining = distance_remaining - (cast_position.distance_to(hit_position_corrected))
			
			cast_position = hit_position_corrected
			prediction_direction = get_new_direction(result.normal, cast_position)
			end_pos = cast_position
			
		else:
			end_pos = cast_position + (prediction_direction * distance_remaining)
			distance_remaining = 0
		
		debug_line.add_point(end_pos - global_position, error)
		
		error = error + 1
		if error > 500:
			print("PlayerPrediction: Couldn't reach a distance remaining of 0, force-exiting the loop", distance_remaining)
			break
	
	return end_pos

func get_new_direction(direction: Vector2, pos: Vector2) -> Vector2:
	
	var new_direction: Vector2 = Vector2.RIGHT
	
	if abs(direction.x) > 0.1:
		#was moving horizontally, return vertical vector
		var possibles_directions = [-1, 1]
		var test_direction: int = possibles_directions[randi_range(0, 1)]
		new_direction = Vector2(0, test_direction)
		if raycast_in_direction(pos, new_direction * (16 * 6)):
			new_direction = Vector2(0, -test_direction)
	else:
		#was moving vertically, return horizontal vector
		var possibles_directions = [-1, 1]
		var test_direction: int = possibles_directions[randi_range(0, 1)]
		new_direction = Vector2(test_direction, 0)
		if raycast_in_direction(pos, new_direction * (16 * 6)):
			new_direction = Vector2(-test_direction, 0)
	
	return new_direction

func raycast_in_direction(start_pos: Vector2, direction: Vector2) -> bool:
	var query = PhysicsRayQueryParameters2D.create(
		start_pos, start_pos + direction, 4, [self, player]
		)
	var result = get_world_2d().direct_space_state.intersect_ray(query)
	
	if result.size() > 0:
		return true
	else:
		return false
