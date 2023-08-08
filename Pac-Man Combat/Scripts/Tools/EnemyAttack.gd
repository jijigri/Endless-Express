class_name EnemyAttack
extends Node2D

var rigidbody

var damage_multiplier = 1.0

var active = true

var locks: int = 0: set = set_locks

var is_locked: bool = false

func set_locks(value):
	locks = clamp(value, 0, 1000)

func _process(delta: float) -> void:
	is_locked = locks > 0

func initialize(rigidbody) -> void:
	self.rigidbody = rigidbody
