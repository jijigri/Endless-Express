class_name ArmoredHealthManager
extends HealthManager

@export var armor_recharge_time: float = 5.0
@export_range(0, 100, 1) var armor_damage_reduction: float = 80.0

var is_armored: bool = true

var current_armor_recharge: float = 0

signal armor_broken
signal armor_repaired

func _process(delta: float) -> void:
	if is_armored == false:
		recharge_armor(delta)

func recharge_armor(delta) -> void:
	current_armor_recharge += delta
	if current_armor_recharge >= armor_recharge_time:
		repair_armor()

func calculate_damage(damage_data: DamageData):
	if damage_data.break_armor > 0.0:
		if is_armored:
			break_armor(damage_data.break_armor)
		else:
			current_armor_recharge = 0
	
	if is_armored:
		var armor_value = damage_data.damage * armor_damage_reduction / 100
		current_health -= (damage_data.damage - armor_value) * damage_multiplier
	else:
		current_health -= damage_data.damage * damage_multiplier

func break_armor(armor_recharge_time: float = 5.0) -> void:
	is_armored = false
	current_armor_recharge = 0
	self.armor_recharge_time = armor_recharge_time
	
	armor_broken.emit()

func repair_armor() -> void:
	is_armored = true
	current_armor_recharge = 0
	
	armor_repaired.emit()

