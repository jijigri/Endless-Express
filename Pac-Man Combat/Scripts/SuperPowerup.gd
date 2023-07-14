extends StaticBody2D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var effect = preload("res://Scenes/Effects/super_powerup_destroy_effect.tscn")

var active = true

func _ready() -> void:
	GameEvents.arena_cleared.connect(_on_arena_clear)
	
	AudioManager.play_sound(
				AudioData.new(preload("res://Audio/SoundEffects/Misc/SuperPowerupAppearSound.wav"),
				global_position)
			)
	
	$Particles.restart()

func _on_health_manager_entity_killed() -> void:
	if active == false:
		return
	
	active = false
	
	player.gain_health(500)
	player.gain_energy(500)
	get_tree().call_group("ArmoredHealthManagers", "break_armor", 20.0)
	
	AudioManager.play_sound(
				AudioData.new(preload("res://Audio/SoundEffects/Misc/SuperPowerupDestroyed.wav"),
				global_position)
			)
	
	Global.spawn_object(effect, global_position)
	
	var instance = Global.spawn_object(ScenesPool.shockwave, global_position)
	instance.initialize(0.5, 90, 0.2, 0.0001)
	
	visible = false
	
	Engine.time_scale = 0.2
	var tween = create_tween()
	tween.tween_property(Engine, "time_scale", 1.0, 0.5).set_ease(Tween.EASE_IN)
	tween.tween_callback(destroy_object)
	tween.play()
	

func _on_arena_clear(arena: Arena):
	destroy_object()

func destroy_object():
	Engine.time_scale = 1.0
	queue_free()
