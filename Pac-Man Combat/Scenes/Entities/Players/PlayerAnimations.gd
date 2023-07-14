class_name PlayerAnimations
extends AnimatedSprite2D

@onready var run_particles: GPUParticles2D = $RunParticles

var player: Player

func set_player(_player: Player):
	self.player = _player

func set_animations(grounded: bool, velocity: Vector2, is_wall_sliding: bool, last_movement_direction_x: int, player_gun):
	
	set_flip(player_gun)
	
	speed_scale = 1
	
	if grounded:
		if abs(velocity.x) > 5:
			play("run")
			run_particles.emitting = true
			if flip_h && velocity.x > 0:
				speed_scale = -1
				run_particles.scale.x = -1
			elif flip_h == false && velocity.x < 0:
				speed_scale = -1
				run_particles.scale.x = -1
			else:
				speed_scale = 1
				run_particles.scale.x = 1
		else:
			play("idle")
			run_particles.emitting = false
	else:
		run_particles.emitting = false
		if !is_wall_sliding:
			#AIR ANIMATIONS
			if velocity.y < 0:
				if animation != "jump":
					play("jump")
			else:
				if animation != "fall":
					play("fall")
		else:
			play("wall_slide")
			flip_h = false if last_movement_direction_x < 0 else true

func set_flip(player_gun):
	flip_h = player_gun.sprite.flip_v
