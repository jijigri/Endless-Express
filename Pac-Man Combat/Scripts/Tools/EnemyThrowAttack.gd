extends EnemyAttack

@export var damage: float = 30.0
@export var rigidbody_to_throw: PackedScene

func throw(velocity: Vector2):
	if !active || is_locked:
		return

	var instance: RigidBody2D = Global.spawn_object(rigidbody_to_throw, global_position)
	instance.apply_central_impulse(velocity)
	
	if instance is Barrel:
		instance.roll_speed = abs(velocity.x) * 1.6
		instance.speed_gain_over_time = 100.0
		instance.direction = sign(velocity.x)
		instance.get_node("CollisionDamage").damage_multiplier = damage_multiplier
