extends StatusEffect

var effect: AnimatedSprite2D
var particles: GPUParticles2D

var entity_speed_gain = 1.4

var initial_nerf_modifier = 1.0

func _initiated():
	super._initiated()
	
	effect = $Effect
	particles = $GPUParticles2D
	
	particles.restart()
	
	var size := Vector3(entity_owner.hurtbox.collision_shape.shape.size.x / 2,entity_owner.hurtbox.collision_shape.shape.size.y / 2, 0)
	particles.process_material.emission_box_extents = size
	particles.process_material.emission_box_extents = size
	particles.amount = (size.x * size.y) / 8.0
	
	for i in entity_owner.movement_states:
		i.speed_modifiers.append(entity_speed_gain)
	
	if entity_owner.is_in_group("Chasers"):
		for i in entity_owner.attacks:
			i.damage_multiplier = 2.0
	
	if entity_owner.sprite != null:
		if entity_owner.sprite is AnimatedSprite2D:
			entity_owner.sprite.speed_scale = entity_speed_gain
	
	initial_nerf_modifier = entity_owner.status_effects_manager.nerf_multiplier
	entity_owner.status_effects_manager.nerf_multiplier = 0.25
	entity_owner.health_manager.damage_modifiers.append(0.4)

func disable_effect(called_from_manager: bool = false):
	
	if !active:
		return
	
	particles.emitting = false
	
	var tween = create_tween()
	tween.tween_property(effect, "modulate:a", 0.0, 0.25)
	tween.play()
	
	for i in entity_owner.movement_states:
		i.speed_modifiers.erase(entity_speed_gain)
	
	if entity_owner.is_in_group("Chasers"):
		for i in entity_owner.attacks:
			i.damage_multiplier = 1.0
	
	if entity_owner.sprite != null:
		if entity_owner.sprite is AnimatedSprite2D:
			entity_owner.sprite.speed_scale = 1.0
	
	entity_owner.status_effects_manager.nerf_multiplier = initial_nerf_modifier
	entity_owner.health_manager.damage_modifiers.erase(0.5)
	
	super.disable_effect(called_from_manager)
