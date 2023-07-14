class_name PlayerHealthManager
extends HealthManager

@export var damage_modifier_curve: Curve
@export var danger_zone_value = 40
@export var danger_damage_modifier = 0.5
@export var iframe_time: float = 0.15
@export var danger_iframe_time: float = 0.3
@export var danger_start_iframe: float = 0.6
@export var healing_modifier_curve: Curve

var current_iframe_time = -100

var is_rolling: bool = false

var iframe_exclusions = []

var screen_effects = ScreenEffects
var is_in_danger: bool = false

signal danger_state_started
signal danger_state_ended

func _ready() -> void:
	HUD.player_hud.on_danger_state_end()

func _process(delta: float) -> void:
	screen_effects.is_in_danger = is_in_danger
	
	if current_iframe_time > -1000:
		current_iframe_time -= delta
		if current_iframe_time <= 0:
			current_iframe_time = -1000
			iframe_exclusions.clear()

func take_damage(damage_data: DamageData) -> void:
	if active == false:
		return
	
	if damage_data.damage > 0:
		if damage_data.source != null:
			if current_iframe_time > 0 && !iframe_exclusions.has(damage_data.source.get_meta("unique_id", 0)):
				return
		
		if is_rolling:
			return
	
	calculate_damage(damage_data)
	calculate_health()
	
	if current_health > danger_zone_value:
		can_be_saved = true
	
	health_updated.emit(current_health, max_health, damage_data)

func calculate_damage(damage_data: DamageData):
	
	var modifier = damage_modifier_curve.sample(current_health / max_health)
	var danger_modifier: float = danger_damage_modifier if is_in_danger else 1.0
	
	current_health -= damage_data.damage * modifier * danger_modifier
	
	current_iframe_time = iframe_time if not is_in_danger else danger_iframe_time
	if damage_data.source != null:
		if damage_data.source.has_meta("unique_id"):
			var id: int = damage_data.source.get_meta("unique_id")
			if !iframe_exclusions.has(id):
				iframe_exclusions.append(id)

func heal(value: float):
	if active == false:
		return
	
	var modifier: float = healing_modifier_curve.sample(current_health / max_health)
	
	current_health += value * modifier
	
	calculate_health()
	
	var damage_data = DamageData.new(-value, global_position)
	health_updated.emit(current_health, max_health, damage_data)

func calculate_health():
	super.calculate_health()
	
	if current_health <= danger_zone_value:
		if is_in_danger == false:
			is_in_danger = true
			danger_zone_start()
	else:
		if is_in_danger:
			is_in_danger = false
			danger_zone_end()

func danger_zone_start():
	current_iframe_time = danger_start_iframe
	iframe_exclusions.clear()
	danger_state_started.emit()
	HUD.player_hud.on_danger_state_start()

func danger_zone_end():
	current_iframe_time = -1000
	danger_state_ended.emit()
	HUD.player_hud.on_danger_state_end()
