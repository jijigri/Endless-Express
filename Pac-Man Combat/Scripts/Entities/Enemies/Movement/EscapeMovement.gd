extends EntityMovement

@export var size_y = 16
@export var escape_player: bool = true

var is_moving: bool
var move_direction: Vector2

var space_state

func _ready() -> void:
	space_state = get_world_2d().direct_space_state
	
	start()

func start() -> void:
	get_starting_direction()
	is_moving = true

func stop() -> void:
	is_moving = false

func update(delta: float) -> void:
	
	if is_moving:
		calculate_direction()
		#rigidbody.apply_central_force(Vector2.RIGHT * move_speed * delta * rigidbody.linear_damp * 100)
		rigidbody.apply_force(move_direction * move_speed * speed_modifier * delta * rigidbody.linear_damp * 100)

func get_starting_direction() -> void:
	var dir = -1
	if !escape_player:
		randomize()
		var array = [-1, 1]
		dir = array[randi_range(0, 1)]
	if player != null:
		move_direction = Helper.to_simple_vector(global_position.direction_to(player.global_position)) * dir

func calculate_direction() -> void:
	if running_into_solid():
		move_direction = find_new_direction()

func find_new_direction():
	var new_direction: Vector2 = move_direction
	
	if abs(move_direction.x) > 0.1:
		#was moving horizontally, return vertical vector
		var possibles_directions = [-1, 1]
		var test_direction: int = possibles_directions[randi_range(0, 1)]
		new_direction = Vector2(0, test_direction)
		if raycast_in_direction(global_position, new_direction * (16 * 6)):
			new_direction = Vector2(0, -test_direction)
	else:
		#was moving vertically, return horizontal vector
		var possibles_directions = [-1, 1]
		var test_direction: int = possibles_directions[randi_range(0, 1)]
		new_direction = Vector2(test_direction, 0)
		if raycast_in_direction(global_position, new_direction * (16 * 6)):
			new_direction = Vector2(-test_direction, 0)
	
	return new_direction

func running_into_solid() -> bool:
	var collision_top = raycast_in_direction(global_position, move_direction * (16 * 3))
	
	return collision_top

func raycast_in_direction(start_pos: Vector2, direction: Vector2) -> bool:
	var query = PhysicsRayQueryParameters2D.create(
		start_pos, start_pos + direction, 4, [self, player]
		)
	var result = space_state.intersect_ray(query)
	
	if result.size() > 0:
		return true
	else:
		return false
