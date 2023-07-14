extends AbilityBase

@export var scene_to_spawn: PackedScene
@export var gun: PlayerGun
@export var throw_force: float = 100

var effect: PackedScene = preload("res://Scenes/Effects/throw_ability_effect.tscn")

func use_ability(player_abilities: PlayerAbilities):
	var spawn_point: Vector2 = Global.get_point_before_collision(global_position, gun.spawn_point.global_position)
	var instance = Global.spawn_object(scene_to_spawn, spawn_point, gun.global_rotation)
	if instance is RigidBody2D:
		instance.apply_impulse((instance.transform.x + (Vector2.UP * .2)) * throw_force)
		instance.apply_torque(10000)
	
	Global.spawn_object(effect, Vector2(), 0, player_abilities.owner)
