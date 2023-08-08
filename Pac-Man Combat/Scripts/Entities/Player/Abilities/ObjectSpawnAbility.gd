extends AbilityBase

@export var scene_to_spawn: PackedScene
@export var gun: PlayerGun
@export var throw_force: float = 100
@export var burst_amount: int = 1
@export var time_between_throws: float = 0.4

var effect: PackedScene = preload("res://Scenes/Effects/throw_ability_effect.tscn")

func use_ability(player_abilities: PlayerAbilities):
	Global.spawn_object(effect, Vector2(), 0, player_abilities.owner)
	
	var _rotation = gun.global_rotation
	for i in burst_amount:
		spawn_scene(_rotation)
		await get_tree().create_timer(time_between_throws).timeout

func spawn_scene(_rotation):
	var spawn_point: Vector2 = Global.get_point_before_collision(global_position, gun.spawn_point.global_position)
	var instance = Global.spawn_object(scene_to_spawn, spawn_point, _rotation)
	if instance is RigidBody2D:
		instance.apply_impulse((instance.transform.x + (Vector2.UP * .2)) * throw_force)
		instance.apply_torque(10000)
