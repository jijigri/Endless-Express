extends StatusEffect

var particles: GPUParticles2D
var drop_particles: GPUParticles2D

func _ready() -> void:
	pass

func _initiated():
	particles = $Particles
	drop_particles = $DropParticles
	
	particles.lifetime = timer.wait_time
	particles.restart()
	drop_particles.restart()
	
	var size := Vector3(entity_owner.collision_shape.shape.size.x,entity_owner.collision_shape.shape.size.y, 0)
	particles.process_material.emission_box_extents = size
	particles.process_material.emission_box_extents = size
	
	for i in entity_owner.movement_states:
		i.stun(timer.wait_time)
	
	if entity_owner.is_in_group("Chasers"):
		for i in entity_owner.attacks:
			i.active = false
	
	entity_owner.frozen = true
	
	if entity_owner.sprite != null:
		if entity_owner.sprite is AnimatedSprite2D:
			entity_owner.sprite.speed_scale = 0.0
	
	entity_owner.health_manager.damage_multiplier = 1.5
	entity_owner.updating_direction = false

func disable_effect(called_from_manager: bool = false):
	
	particles.emitting = false
	drop_particles.emitting = false
	
	if entity_owner.is_in_group("Chasers"):
		for i in entity_owner.attacks:
			i.active = true
	
	entity_owner.frozen = false
	
	if entity_owner.sprite != null:
		if entity_owner.sprite is AnimatedSprite2D:
			entity_owner.sprite.speed_scale = 1.0
	
	entity_owner.health_manager.damage_multiplier = 1.0
	entity_owner.updating_direction = true
	
	super.disable_effect(called_from_manager)
