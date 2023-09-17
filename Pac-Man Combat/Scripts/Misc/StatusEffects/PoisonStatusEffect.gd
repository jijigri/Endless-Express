extends StatusEffect

@export var armor_recharge_reduction_value: float = 0.25
@export var damage_modifier_value: float = 1.25
@export var tick_time: float = 0.25
@export var tick_damage: float = 1.0

var particles: GPUParticles2D

func _initiated():
	
	super._initiated()
	
	particles = $Particles
	
	particles.restart()
	
	var size := Vector3(entity_owner.hurtbox.collision_shape.shape.size.x / 2,entity_owner.hurtbox.collision_shape.shape.size.y / 2, 0)
	particles.process_material.emission_box_extents = size
	particles.process_material.emission_box_extents = size
	
	if entity_owner.health_manager is ArmoredHealthManager:
		entity_owner.health_manager.armor_recharge_modifiers.append(armor_recharge_reduction_value)
	
	entity_owner.health_manager.damage_modifiers.append(damage_modifier_value)
	
	tick()

func tick():
	while active:
		if active:
			var damage_data = DamageData.new(tick_damage, global_position)
			entity_owner.health_manager.take_damage(damage_data)
		await get_tree().create_timer(tick_time).timeout

func disable_effect(called_from_manager: bool = false):
	if !active:
		return
	
	particles.emitting = false

	if entity_owner.health_manager is ArmoredHealthManager:
		entity_owner.health_manager.armor_recharge_modifiers.erase(armor_recharge_reduction_value)
	
	entity_owner.health_manager.damage_modifiers.erase(damage_modifier_value)
	
	super.disable_effect(called_from_manager)
