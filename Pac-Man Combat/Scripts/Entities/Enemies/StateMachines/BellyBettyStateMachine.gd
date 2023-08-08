extends ChaserStateMachine

@export var time_to_explode: float = 1.0
@export var explosion_size: float = 64.0
@export var explosion_damage: float = 80.0
@export var explosion_scene: PackedScene
@export var player_explosion_size: float = 64.0
@export var player_explosion_damage: float = 40.0

@onready var normal_explosion: PackedScene = preload("res://Scenes/Entities/Misc/explosion.tscn")

@onready var inflate_sound: AudioStream = preload("res://Audio/SoundEffects/Enemies/BellyBetty/BellyBettyInflateSound.wav")
@onready var warning_sound: AudioStream = preload("res://Audio/SoundEffects/Enemies/BellyBetty/BellyBettyWarningSound.wav")

var can_explode := true

func _ready() -> void:
	super._ready()
	default_movement.max_time = default_movement.max_time + randf_range(-10.0, 20.0)
	

func _process(delta: float) -> void:
	
	super._process(delta)
	
	if can_explode == false:
		return
	
	if frozen || is_staggered():
		return
	
	if current_state == default_movement:
		var speed = current_state.current_speed * current_state.speed_modifier
		var dist = (speed * 0.25) * (time_to_explode)
		dist = clamp(dist, 32.0, 320.0)
		
		var distance = distance_to_player
		if current_state.is_rushing == false:
			current_state.agent.distance_to_target()
		if  distance < dist:
			explode()

func explode():
	can_explode = false
	
	sprite.play("warmup")
	
	var audio_data = AudioData.new(inflate_sound, global_position)
	audio_data.max_distance = 3000
	audio_data.attenuation = 1.5
	audio_data.volume = 2.0
	AudioManager.play_sound(audio_data)
	
	await get_tree().create_timer(time_to_explode).timeout
	
	if frozen || is_staggered():
		can_explode = true
		return
	
	var instance = Global.spawn_object(explosion_scene, global_position)
	instance.initialize(explosion_size, explosion_damage, 0.0)

	kill()

func _on_health_manager_entity_killed() -> void:
	var instance = Global.spawn_object(normal_explosion, global_position)
	instance.initialize(player_explosion_size, player_explosion_damage, 5.0)
	super._on_health_manager_entity_killed()


func _on_sprite_animation_finished() -> void:
	if sprite.animation == "warmup":
		sprite.play("warmup_loop")

func _on_sprite_frame_changed() -> void:
	if sprite.animation == "warmup_loop":
		if sprite.frame == 0 || sprite.frame == 2:
			var audio_data = AudioData.new(warning_sound, global_position)
			audio_data.max_distance = 600
			audio_data.attenuation = 1.5
			audio_data.volume = 2.0
			AudioManager.play_sound(audio_data)

func _on_status_effects_manager_effect_applied(effect, duration) -> void:
	sprite.play("default")


