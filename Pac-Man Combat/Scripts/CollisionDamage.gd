class_name CollisionDamage
extends EnemyAttack

@export var damage: float
@export var auto_monitor: bool = true

@onready var area: Area2D = $Area2D
@onready var timer: Timer = $Area2D/Timer
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D

var can_attack: bool = true

signal damage_dealt

func _on_area_2d_area_entered(area: Area2D) -> void:
	if !auto_monitor:
		return
	
	if !active:
		return
	
	if !can_attack:
		return
	
	if area.is_in_group("Hurtbox"):
		if area.has_method("receive_hit"):
			var damageData = DamageData.new(damage, global_position, Vector2())
			damageData.source = self
			area.receive_hit(damageData)
			timer.start()
			damage_dealt.emit()
			can_attack = false

func check_damage():
	if !active:
		return
	
	if !can_attack:
		return
	
	for hit in area.get_overlapping_areas():
		if hit.is_in_group("Hurtbox"):
			if hit.has_method("receive_hit"):
				var damageData = DamageData.new(damage, global_position, Vector2())
				damageData.source = self
				hit.receive_hit(damageData)
				timer.start()
				can_attack = false

func _on_timer_timeout() -> void:
	can_attack = true
