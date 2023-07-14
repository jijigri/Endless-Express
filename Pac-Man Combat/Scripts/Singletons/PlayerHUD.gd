class_name PlayerHUD
extends Control

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var back_health: TextureProgressBar = $HealthBarBack

@onready var energy_bar: TextureProgressBar = $EnergyBar
@onready var back_energy: TextureProgressBar = $EnergyBarBack

@onready var movement_ability = $MovementAbility

var abilities: Array[Sprite2D]

var health_tween
var energy_tween

func _ready() -> void:
	for i in $Abilities.get_children():
		abilities.append(i)

func update_health_bar(current_health: float, max_health: float, damage_data: DamageData):
	health_bar.max_value = max_health
	back_health.max_value = max_health
	
	if damage_data == null:
		health_bar.value = current_health
		back_health.value = current_health
		return
	
	var value = current_health
	if value < 3 && value > 0:
		value = 3
	
	if health_tween != null:
		health_tween.kill()
	if damage_data.damage > 0:
		decrease_value(health_bar, back_health, value)
	elif damage_data.damage < 0:
		increase_value(health_bar, back_health, value)

func update_energy_bar(current_energy: float, max_energy: float, gain: bool):
	energy_bar.max_value = max_energy
	back_energy.max_value = max_energy
	
	if energy_tween != null:
		energy_tween.kill()
	if gain:
		increase_value(energy_bar, back_energy, current_energy, false)
	else:
		decrease_value(energy_bar, back_energy, current_energy, false)


func decrease_value(bar: TextureProgressBar, back_bar: TextureProgressBar, value: float, health := true) -> void:
	
	bar.value = value
	
	if health:
		health_tween = create_tween()
		health_tween.tween_property(back_bar, "value", value, 0.4).set_delay(0.1)
		health_tween.play()
	else:
		energy_tween = create_tween()
		energy_tween.tween_property(back_bar, "value", value, 0.4).set_delay(0.1)
		energy_tween.play()

func increase_value(bar: TextureProgressBar, back_bar: TextureProgressBar, value: float, health := true) -> void:
	
	back_bar.value = value
	
	if health:
		health_tween = create_tween()
		health_tween.tween_property(bar, "value", value, 0.4).set_delay(0.1)
		health_tween.play()
	else:
		energy_tween = create_tween()
		energy_tween.tween_property(bar, "value", value, 0.4).set_delay(0.1)
		energy_tween.play()

func on_danger_state_start():
	health_bar.material.set_shader_parameter("STRENGTH", 1)

func on_danger_state_end():
	health_bar.material.set_shader_parameter("STRENGTH", 0)

func set_ability_icon(index: int, sprite: Texture, keybind: String):
	if abilities.size() > index:
		if sprite != null:
			abilities[index].get_node("Icon").texture = sprite
		abilities[index].keybind.text = keybind

func set_movement_ability_icon(sprite: Texture, keybind: String):
	movement_ability.icon.texture = sprite
	movement_ability.keybind.text = keybind

func update_ability(index: int, current_value: float, max_value: float):
	if abilities.size() <= index:
		return
	
	var tiled_bar = abilities[index].tiled_bar
	tiled_bar.position.x = -((max_value * 0.4642857143) / 2) / 2
	tiled_bar.max_value = (max_value * 0.4642857143) / 2
	tiled_bar.value = (current_value * 0.4642857143) / 2
	
	if current_value >= max_value:
		if abilities[index].is_available == false:
			abilities[index].on_ability_available()
	else:
		if abilities[index].is_available == true:
			abilities[index].on_ability_unavailable()

func update_movement_ability(current_value: float, max_value: float):
	
	movement_ability.set_progress(current_value, max_value)
	if current_value <= 0:
		if movement_ability.is_available == false:
			movement_ability.on_ability_available()
	else:
		if movement_ability.is_available == true:
			movement_ability.on_ability_unavailable()

func update_ammos(ammos: int):
	pass
