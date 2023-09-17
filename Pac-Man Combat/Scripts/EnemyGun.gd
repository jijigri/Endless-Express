class_name EnemyGun
extends Node2D

@export var spawn_point: Node2D
@export var gun: Gun
@export var enemy: RigidBody2D

@onready var anchor = self
@onready var sprite: Sprite2D = $Sprite
@onready var outline: Sprite2D = $Sprite/Outline
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var particles: PackedScene = preload("res://Scenes/Effects/drop_particles.tscn")

@onready var initial_gun_damage: float = gun.damage

var parent = null

func _process(delta: float) -> void:
	var rot = Helper.angle_between(global_position, player.global_position)
	rotation_degrees = (rot)

	if enemy.sprite.scale.x > 0:
		sprite.flip_v = true
		outline.flip_v = true
	else:
		sprite.flip_v = false
		outline.flip_v = false
	
	if parent != null && gun != null:
		gun.can_shoot = !parent.is_locked && parent.active

func shoot(multiplier: float, parent = null):
	gun.damage = initial_gun_damage * multiplier
	gun.shoot(self, false)
	
	self.parent = parent
