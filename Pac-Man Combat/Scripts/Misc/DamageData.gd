class_name DamageData

var damage: float
var velocity: Vector2
var hit_position: Vector2
var break_armor: float = 0.0
var source: Node2D

func _init(damage: float, hit_position: Vector2, velocity: Vector2 = Vector2(), break_armor: float = 0.0) -> void:
	self.damage = damage
	self.hit_position = hit_position
	self.velocity = velocity
	self.break_armor = break_armor
