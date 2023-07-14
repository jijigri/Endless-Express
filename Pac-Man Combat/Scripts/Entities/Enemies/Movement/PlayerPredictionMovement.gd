extends PathfindingMovement

@export var min_predict_distance_in_tiles: int = 24
@export var max_predict_distance_in_tiles: int = 999
@export var rush_update_time: float = 0.1
@export var max_rush_distance: float = 12.0
@export var distance_from_player_to_rush_in_tiles = 8
@export var speed_over_distance: Curve
@export var max_distance: float = 1000
@export var dumb_prediction: bool = false
@export_range(0.1, 20.0, 0.5) var dumb_player_velocity_damp = 5.0

@onready var debug_line: Line2D = $DebugLine
@onready var rush_timer: Timer = $RushTimer

var update_time: float

var last_player_velocity: Vector2 = Vector2()

var can_rush: bool = true
var is_rushing: bool = false

func _ready() -> void:
	super._ready()
	update_time = path_timer.wait_time
	debug_line.reparent.call_deferred(get_tree().root.get_node("Game"))
	debug_line.set_deferred("global_position", Vector2.ZERO)

func _process(delta: float) -> void:
	if speed_over_distance != null:
		if rigidbody != null:
			var distance = clamp(rigidbody.distance_to_player, 0, max_distance)
			var modifier = speed_over_distance.sample(distance / max_distance)
			current_speed = move_speed * modifier
	super._process(delta)

func update(delta: float) -> void:
	if is_rushing == false:
		get_player_velocity()
		
		if can_rush:
			if owner.distance_to_player < distance_from_player_to_rush_in_tiles * 16:
				if is_player_visible(rigidbody.distance_to_player):
					start_rushing()
	else:
		if owner.distance_to_player > max_rush_distance * 16.0:
			if is_rushing:
				stop_rushing()
	
	super.update(delta)

func update_path() -> void:
	
	if is_rushing == false:
		if dumb_prediction == false:
			target_position = get_prediction_position()
		else:
			target_position = get_dumb_prediction_position()
	else:
		target_position = player.global_position
	
	super.update_path()

func get_player_velocity() -> void:
	if player.velocity.length_squared() > 40000:
		last_player_velocity = player.velocity
		if player.is_wall_sliding:
			last_player_velocity.x = 0
		else:
			last_player_velocity.y = 0
		

func get_prediction_position() -> Vector2:
	
	var prediction_direction = last_player_velocity.normalized()
	#var distance_remaining = 16 * predict_distance_in_tiles
	var distance_remaining = clamp(
		global_position.distance_to(player.global_position),
		min_predict_distance_in_tiles * 16,
		max_predict_distance_in_tiles * 16
		)
	if player.velocity.length() < 50:
		distance_remaining *= 0
	
	var cast_position = player.global_position
	
	var space_state = get_world_2d().direct_space_state
	
	var end_pos = player.global_position + prediction_direction
	
	debug_line.clear_points()
	debug_line.add_point(player.global_position, 0)
	
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
		
		debug_line.add_point(end_pos, error)
		
		error = error + 1
		if error > 500:
			print("PlayerPrediction: Couldn't reach a distance remaining of 0, force-exiting the loop", distance_remaining)
			break
	
	return end_pos

func get_dumb_prediction_position() -> Vector2:
	
	var prediction_direction = player.velocity / dumb_player_velocity_damp / clamp(time_since_last_speed_reset * 0.1, 1.0, max_time)
	
	var length = clamp(
		prediction_direction.length(),
		min_predict_distance_in_tiles * 16 / clamp(time_since_last_speed_reset * 0.1, 1.0, max_time),
		max_predict_distance_in_tiles * 16
		)
	var clamped_direction = prediction_direction.normalized() * length
	
	var player_position = player.global_position
	var final_position = player_position + clamped_direction
	
	debug_line.clear_points()
	debug_line.add_point(player.global_position, 0)
	debug_line.add_point(final_position, 1)
	
	return final_position

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

func _on_navigation_agent_2d_navigation_finished() -> void:
	path_timer.start()
	update_path()
	update_path()


func _on_rush_timer_timeout() -> void:
	stop_rushing()

func start_rushing() -> void:
	
	#get_parent().get_node("Sprite2D").modulate = Color.DARK_RED
	path_timer.wait_time = rush_update_time
	path_timer.start()
	rush_timer.start()
	
	is_rushing = true
	update_path()

func stop_rushing() -> void:
	
	#get_parent().get_node("Sprite2D").modulate = Color.CORNFLOWER_BLUE
	path_timer.wait_time = update_time
	path_timer.start()
	rush_cooldown()
	
	is_rushing = false
	update_path()

func rush_cooldown() -> void:
	can_rush = false
	await get_tree().create_timer(3.5).timeout
	can_rush = true
