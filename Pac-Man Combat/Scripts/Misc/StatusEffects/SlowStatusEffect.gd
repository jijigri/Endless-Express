extends StatusEffect

var particles: GPUParticles2D

var value: float = 0.65

func _initiated():
	
	super._initiated()
	
	particles = $Particles
	
	particles.restart()
	
	var size := Vector3(entity_owner.hurtbox.collision_shape.shape.size.x / 2,entity_owner.hurtbox.collision_shape.shape.size.y / 2, 0)
	particles.process_material.emission_box_extents = size
	particles.process_material.emission_box_extents = size
	
	if entity_owner is Player:
		entity_owner.speed_modifiers.append(value)
	else:	
		for i in entity_owner.movement_states:
			i.speed_modifiers.append(value)

	if entity_owner.sprite != null:
		if entity_owner.sprite is AnimatedSprite2D:
			entity_owner.sprite.speed_scale = value

func disable_effect(called_from_manager: bool = false):
	if !active:
		return
	
	particles.emitting = false
	
	if entity_owner is Player:
		entity_owner.speed_modifiers.erase(value)
	else:	
		for i in entity_owner.movement_states:
			i.speed_modifiers.erase(value)

	if entity_owner.sprite != null:
		if entity_owner.sprite is AnimatedSprite2D:
			entity_owner.sprite.speed_scale = 1.0
	
	super.disable_effect(called_from_manager)
