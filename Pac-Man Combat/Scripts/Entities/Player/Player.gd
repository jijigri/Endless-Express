class_name Player
extends PlayerMovement

@onready var health_manager: HealthManager = $HealthManager
@onready var energy_manager: EnergyManager = $EnergyManager
@onready var camera: Camera2D = $Camera
@onready var player_gun = $PlayerGun

func _ready() -> void:
	HUD.player_hud.update_health_bar(health_manager.current_health, health_manager.max_health, null)
	HUD.player_hud.update_energy_bar(energy_manager.current_energy, energy_manager.max_energy, true)
	CameraManager.current_camera = camera
	
	sprite.set_player(self)

func _process(delta: float) -> void:
	super._process(delta)
	set_animations()
	
	"""
	if Input.is_action_just_pressed("ability_4"):
		var image = get_viewport().get_texture().get_image()
		var path: String = "D:/Godot Games/Footage/" + Time.get_date_string_from_system() + str(randf_range(0.0, 1000.0)) + ".png"
		image.save_png(path)
	"""

func _on_health_manager_health_updated(current_health, max_health, damage_data) -> void:
	HUD.player_hud.update_health_bar(current_health, max_health, damage_data)
	
	if damage_data.damage > 0:
		AudioManager.play_sound( 
				AudioData.new(preload(AudioManager.AUDIO_PATH + "Player/PlayerHit.wav"),
				global_position)
			)
	
		modulate.a = 0
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1, 0.25)
		tween.play()
		
		ScreenEffects.damage_effect(0.1)
		
		GameEvents.player_damaged.emit(current_health, max_health, damage_data.damage)
	elif damage_data.damage <= -8:
		ScreenEffects.heal_effect(0.05)
		
		GameEvents.player_healed.emit(current_health, max_health, abs(damage_data.damage))
	
func _on_energy_manager_energy_updated(current_energy, max_energy, gain) -> void:
	HUD.player_hud.update_energy_bar(current_energy, max_energy, gain)
	
	if gain >= 8:
		ScreenEffects.energy_effect(0.05)

func _on_health_manager_entity_killed() -> void:
	GameEvents.player_killed.emit()
	visible = false
	set_process(false)
	set_physics_process(false)
	
	player_gun.set_process(false)
	$PlayerAbilities.set_process(false)

func gain_health(value: float):
	health_manager.heal(value)

func gain_energy(value: float):
	energy_manager.add_energy(value)

func set_animations():
	
	sprite.set_animations(
		is_on_floor(), velocity, is_wall_sliding, last_movement_direction_x, player_gun
		)
	

func _on_sprite_frame_changed() -> void:
	if sprite == null:
		return
	
	if sprite.animation == "run":
		if sprite.frame == 1 || sprite.frame == 5:
			AudioManager.play_sound(
				AudioData.new(preload("res://Audio/SoundEffects/Player/PlayerStep.wav"),
				global_position)
			)
