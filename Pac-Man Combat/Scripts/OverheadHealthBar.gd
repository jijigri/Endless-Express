class_name OverheadHealthBar
extends TextureProgressBar

@export var health_manager: Node2D

@onready var back_bar: TextureProgressBar = $BackHealthBar
@onready var tint: Color = tint_progress

var tween

func _ready() -> void:
	if health_manager is HealthManager:
		if health_manager.has_signal("health_updated"):
			health_manager.health_updated.connect(_on_health_updated)
				
		change_values(health_manager.current_health, health_manager.max_health, false)
	elif health_manager is EnergyManager:
		if health_manager.has_signal("energy_updated"):
			health_manager.energy_updated.connect(_on_energy_updated)
			
		change_values(health_manager.current_energy, health_manager.max_energy, false)

func _on_health_updated(current_health: float, max_health: float, damage_data: DamageData):
	change_values(current_health, max_health, damage_data.damage > 0)

func _on_energy_updated(current: float, max: float, gain: float):
	change_values(current, max, gain)

func change_values(value: float, max_value: float, is_decrease: bool):
	self.max_value = max_value
	back_bar.max_value = max_value
	
	if tween != null:
		tween.kill()
	
	if is_decrease:
		decrease_value(value)
	else:
		increase_value(value)
	
	tint_flash()

func tint_flash():
	tint_progress = Color.WHITE
	var tint_tween = create_tween()
	tint_tween.tween_property(self, "tint_progress", tint, 0.1)
	tint_tween.play()

func decrease_value(value: float) -> void:
	
	self.value = value
	
	tween = create_tween()
	tween.tween_property(back_bar, "value", value, 0.4).set_delay(0.1)
	tween.play()

func increase_value(value: float) -> void:
	
	back_bar.value = value
	
	tween = create_tween()
	tween.tween_property(self, "value", value, 0.4).set_delay(0.1)
	tween.play()
