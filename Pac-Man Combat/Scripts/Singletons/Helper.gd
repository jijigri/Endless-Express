extends Node

func to_simple_vector(vector: Vector2, priority_x: bool = true) -> Vector2:
	if priority_x:
		if vector.x != 0:
			return Vector2(sign(vector.x), 0)
		elif vector.y != 0:
			return Vector2(0, sign(vector.y))
	else:
		if vector.y != 0:
			return Vector2(0, sign(vector.y))
		elif vector.x != 0:
			return Vector2(sign(vector.x), 0)
	
	return Vector2.UP

func angle_between(origin: Vector2, target: Vector2):
		return rad_to_deg(atan2(target.y - origin.y, target.x - origin.x))

func randv_circle(min_radius := 1.0, max_radius := 1.0) -> Vector2:
	var r2_max := max_radius * max_radius
	var r2_min := min_radius * min_radius
	var r := sqrt(randf() * (r2_max - r2_min) + r2_min)
	var t := randf() * TAU
	return Vector2(r, 0).rotated(t)

func randv_rect(rect: Rect2, random_offset: float, exclude_edges: Vector2 = Vector2.ZERO) -> Vector2:
	
	var axis_direction: Vector2
	var random: float = randf_range(0, rect.size.x + rect.size.y)
	var rand_direction = [-1, 1]
	if random < rect.size.x:
		axis_direction = Vector2(0, rand_direction[randi_range(0, rand_direction.size() -1)])
		if exclude_edges.y == axis_direction.y:
			axis_direction.y = axis_direction.y * -1
	else:
		axis_direction = Vector2(rand_direction[randi_range(0, rand_direction.size() -1)], 0)
		if exclude_edges.x == axis_direction.x:
			axis_direction.x = axis_direction.x * -1
	
	var direction = axis_direction * (rect.size / 2)
	var side_offset_size = 0
	if axis_direction.x != 0:
		side_offset_size = rect.size.y / 2
	else:
		side_offset_size = rect.size.x / 2
	
	var offset_dir = Vector2(abs(axis_direction.y), abs(axis_direction.x))
	var side_offset = offset_dir * randf_range(-side_offset_size, side_offset_size)
	direction += side_offset
	
	if random_offset > 0:
		var rand_offset = randf_range(0, random_offset)
		direction -= axis_direction * rand_offset
	
	return rect.get_center() + direction

func polar2cartesian(length, angle) -> Vector2:
	var value := Vector2()
	value.x = length * cos(angle)
	value.y = length * sin(angle)
	
	return value
