extends Area2D

@export var health_manager: HealthManager
@export var status_effects_manager: StatusEffectsManager

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func receive_hit(damageData: DamageData):
	if health_manager == null:
		print_debug("Couldn't process hitbox hit as no HealthManager was provided")
		return
	
	health_manager.take_damage(damageData)
