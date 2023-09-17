class_name PlayerAnimator
extends AnimatedSprite2D

@export var speed_modifier = 1.0

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var run_particles: GPUParticles2D = $RunParticles

var player: Player

func set_player(_player: Player):
	self.player = _player

func set_animations(grounded: bool, velocity: Vector2, is_wall_sliding: bool, last_movement_direction_x: int, player_gun):
	
	set_flip(player_gun)
	
	animator.speed_scale = 1 * speed_modifier
	
	if grounded:
		if abs(velocity.x) > 20:
			animator.play("run")
			run_particles.emitting = true
			if flip_h && velocity.x > 0:
				animator.speed_scale = -1 * speed_modifier
				run_particles.scale.x = -1
			elif flip_h == false && velocity.x < 0:
				animator.speed_scale = -1 * speed_modifier
				run_particles.scale.x = -1
			else:
				animator.speed_scale = 1 * speed_modifier
				run_particles.scale.x = 1
		else:
			if !animator.current_animation == "idle":
				animator.play("idle")
			run_particles.emitting = false
	else:
		run_particles.emitting = false
		if !is_wall_sliding:
			#AIR ANIMATIONS
			if velocity.y < 0:
				if animator.current_animation != "jump":
					animator.play("jump")
			else:
				if animator.current_animation != "fall":
					animator.play("fall")
		else:
			animator.play("wall_slide")
			flip_h = false if last_movement_direction_x < 0 else true

func set_flip(player_gun):
	var mouse_rotation = Helper.angle_between(player.global_position, get_global_mouse_position())
	if mouse_rotation < -90 || mouse_rotation > 90:
		flip_h = true
	else:
		flip_h = false
