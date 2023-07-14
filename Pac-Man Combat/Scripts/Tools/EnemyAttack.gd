class_name EnemyAttack
extends Node2D

var rigidbody

var damage_multiplier = 1.0

var active = true

func initialize(rigidbody) -> void:
	self.rigidbody = rigidbody
