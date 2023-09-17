extends PlayerAnimator

var is_dashing: bool = false
var is_dash_charged: bool = false

func set_animations(grounded: bool, velocity: Vector2, is_wall_sliding: bool, last_movement_direction_x: int, player_gun):
	
	if is_dashing:
		if is_dash_charged == false:
			print_debug("Normal dash")
			if animator.current_animation != "dash":
				animator.play("dash")
		else:
			if animator.current_animation != "charged_dash":
				animator.play("charged_dash")
		return
	
	super.set_animations(grounded, velocity, is_wall_sliding, last_movement_direction_x, player_gun)

func set_flip(player_gun):
	if !is_dashing:
		super.set_flip(player_gun)
