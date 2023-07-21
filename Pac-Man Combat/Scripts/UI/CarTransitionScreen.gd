extends Control

@onready var car1: TextureRect
@onready var car2: TextureRect
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

signal transition_complete

func _ready() -> void:
	
	audio.volume_db = -40.0
	
	var tween = create_tween()
	tween.tween_property(audio, "volume_db", 0.0, 0.2)
	tween.play()
	
	await get_tree().create_timer(5.0).timeout
	
	queue_free()

func initialize(old_score, new_score) -> void:
	car1 = %Car
	car2 = %Car2
	
	car1.get_node("Label").text = str(old_score)
	car2.get_node("Label").text = str(new_score)

func on_animation_collision() -> void:
	CameraManager.shake(8, 0.25)
	
	var audio_data = AudioData.new(preload("res://Audio/SoundEffects/UI/CarTransitionCollisionSound.wav"), global_position)
	audio_data.attenuation = 0.0
	audio_data.max_distance = 2000.0
	audio_data.panning_strength = 0.0
	AudioManager.play_sound(audio_data)

func animation_end() -> void:
	transition_complete.emit()
	
	var tween = create_tween()
	tween.tween_property(audio, "volume_db", -40.0, 3.0)
	tween.play()
