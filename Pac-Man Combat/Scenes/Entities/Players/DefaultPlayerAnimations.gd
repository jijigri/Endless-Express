extends PlayerAnimations

var is_rolling: bool = false
var is_diving: bool = false

func dive(input_direction):
	is_diving = true
	flip_h = input_direction == -1
	
	play("dive_up")
	
	speed_scale = 1

func roll(input_direction, roll_invulnerability_time):
	is_rolling = true
	flip_h = input_direction == -1
	
	speed_scale = 1
	play("roll")
	
	await get_tree().create_timer(roll_invulnerability_time).timeout
	is_rolling = false

func set_animations(grounded: bool, velocity: Vector2, is_wall_sliding: bool, last_movement_direction_x: int, player_gun):
	
	if is_diving:
		if grounded || is_wall_sliding:
			is_diving = false
		
		if velocity.y < 0:
			if animation != "dive_up":
				play("dive_up")
			return
		else:
			if animation != "dive_down":
				play("dive_down")
			return
	
	if is_rolling:
		if grounded == false:
			is_rolling = false
		
		if animation != "roll":
			play("roll")
		return
	
	super.set_animations(grounded, velocity, is_wall_sliding, last_movement_direction_x, player_gun)

func set_flip(player_gun):
	if !is_diving && !is_rolling:
		super.set_flip(player_gun)


func _on_animation_finished() -> void:

	if animation == "roll":
		if is_rolling:
			is_rolling = false
