class_name Explosion
extends Area2D

@export var sound: AudioStream
@export var enemy_push_multiplier = 1.0
@export var player_push_force = 5500.0
@export var damage_player: bool = false

var has_exploded = false

var damage: float = 40
var size: float = 16

var armor_break_time: float = 0.0

func _ready() -> void:
	if has_exploded:
		return
	
	$FlashParticles.restart()
	$DustParticles.restart()
	explode()

func initialize(size: float, damage: float, break_armor: float = 0.0):
	if has_exploded:
		return
	
	self.damage = damage
	self.size = size
	
	armor_break_time = break_armor
	
	$CollisionShape2D.shape.radius = size
	var process: ParticleProcessMaterial = $FlashParticles.process_material
	process.scale_min = (size * 2) / 128
	process.scale_max = (size * 2) / 128
	var dust_particles: GPUParticles2D = $DustParticles
	dust_particles.process_material.emission_sphere_radius = size * 0.8
	dust_particles.amount = size * (dust_particles.amount / 64.0)
	dust_particles.process_material.scale_min = size * (0.025 / 64)
	dust_particles.process_material.scale_max = clamp(size * (0.2 / 64), 0.01, 0.2)

func explode():
	has_exploded = true

	play_sound()
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	var space_state = get_world_2d().direct_space_state
	
	#IF PROBLEM WITH THE BOMB, LIKELY COMES FROM PLATFORM CHECK
	
	var hits = get_overlapping_areas()
	for hit in hits:
		if hit.is_in_group("Hurtbox"):
			if  damage_player || !hit.has_meta("isPlayer"):
				var query = PhysicsRayQueryParameters2D.create(global_position, hit.global_position, 4)
				var result = space_state.intersect_ray(query)
				if result.size() <= 0 || result.collider.is_in_group("Platform"):
					on_hit(hit)
	
	if damage_player == false:
		var bodies = get_overlapping_bodies()
		for body in bodies:
			if body is PlayerMovement:
				var query = PhysicsRayQueryParameters2D.create(global_position, body.global_position, 4)
				var result = space_state.intersect_ray(query)
				if result.size() <= 0:
					on_player_hit(body)
	
	set_shake()
	
	await get_tree().create_timer(2.0).timeout
	queue_free()

func on_hit(hit):
	var hit_velocity = (hit.global_position - global_position) * (size / 4)
	hit.receive_hit(DamageData.new(damage, hit.global_position, hit_velocity * enemy_push_multiplier, armor_break_time))

func on_player_hit(body):
	var distance = global_position.distance_to(body.global_position)
	distance = clamp(distance, 12, 14)
	var hit_velocity = global_position.direction_to(body.global_position).normalized() * (1.0 / distance)
	body.velocity += hit_velocity * player_push_force

func play_sound():
	if sound != null:
		var data = AudioData.new(sound, global_position)
		data.max_distance = 440
		AudioManager.play_sound(data)

func set_shake():
	CameraManager.shake(0.04 * size, 0.1 + (size / 4000), false)
