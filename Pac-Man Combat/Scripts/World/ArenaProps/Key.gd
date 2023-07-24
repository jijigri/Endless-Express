extends Area2D

@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var obtained_sound = preload("res://Audio/SoundEffects/ArenaProps/LockBlock/KeyObtainedSound.wav")

var active: bool = true

signal obtained(key: Node2D)

func _on_body_entered(body: Node2D) -> void:
	if active:
		if body.is_in_group("Player"):
			key_obtained()

func key_obtained():
	obtained.emit(self)
	active = false
	
	sprite.play("obtained")
	
	var audio_data = AudioData.new(obtained_sound, global_position)
	audio_data.attenuation = 0.0
	audio_data.max_distance = 5000
	AudioManager.play_sound(audio_data)
	
	await get_tree().create_timer(1.0).timeout
	
	queue_free()
