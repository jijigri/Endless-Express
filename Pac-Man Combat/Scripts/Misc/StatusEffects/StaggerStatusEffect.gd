extends StatusEffect

var particles: GPUParticles2D

func _initiated():
	particles = $Particles
	
	for status in manager.current_effects:
		if status.effect_name == effect_name:
			timer.wait_time += status.timer.time_left / 4
	timer.start()
	
	particles.lifetime = 0.3
	particles.restart()
	
	var size := Vector3(entity_owner.hurtbox.collision_shape.shape.size.x / 2,entity_owner.hurtbox.collision_shape.shape.size.y / 2, 0)
	particles.process_material.emission_box_extents = size
	particles.process_material.emission_box_extents = size
	
	for i in entity_owner.movement_states:
		i.speed_modifiers.append(0.5)
	
	if entity_owner.is_in_group("Chasers"):
		for i in entity_owner.attacks:
			i.locks += 1
	
	entity_owner.stagger_stacks += 1
	
func disable_effect(called_from_manager: bool = false):
	
	if !active:
		return
	
	particles.emitting = false
	particles.visible = false
	
	if entity_owner.is_in_group("Chasers"):
		for i in entity_owner.attacks:
			i.locks -= 1
	
	for i in entity_owner.movement_states:
		i.speed_modifiers.erase(0.5)
	
	entity_owner.stagger_stacks -= 1
	
	super.disable_effect(called_from_manager)
