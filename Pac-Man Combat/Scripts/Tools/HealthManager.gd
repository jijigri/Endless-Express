class_name HealthManager
extends Node2D

@export var max_health: float = 100
@export var health_to_kill = 0

@onready var current_health: float = max_health

var damage_multiplier = 1.0
var damage_modifiers = []

signal health_updated(current_health: float, max_health: float, damage_data: DamageData)
signal entity_killed()
signal damage_tanked(damage_data)

var can_be_saved: bool = true

var active: bool = true

var invincible: bool = false

func take_damage(damage_data: DamageData) -> void:
	if active == false:
		return
	
	if invincible:
		damage_tanked.emit(damage_data)
		return
	
	calculate_damage(damage_data)
	calculate_health()
	
	health_updated.emit(current_health, max_health, damage_data)

func calculate_damage(damage_data: DamageData):
	var modifier = 1.0
	for i in damage_modifiers:
		modifier *= i
	current_health -= damage_data.damage * damage_multiplier * modifier

func heal(value: float):
	if active == false:
		return
	
	if invincible:
		return
	
	current_health += value
	
	calculate_health()
	
	var damage_data = DamageData.new(-value, global_position)
	health_updated.emit(current_health, max_health, damage_data)

func calculate_health() -> void:
	if current_health > max_health:
		current_health = max_health
	elif current_health <= health_to_kill || (current_health <= 0 && !can_be_saved):
		kill()
	elif current_health <= 0:
		current_health = 1
		set_save_cooldown()

func set_save_cooldown():
	await get_tree().create_timer(0.15).timeout
	can_be_saved = false

func kill() -> void:
	active = false
	entity_killed.emit()
