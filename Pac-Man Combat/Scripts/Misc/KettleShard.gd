extends AnimatedSprite2D

var appear_sound = preload("res://Audio/SoundEffects/Misc/KettleShardAppearSound.wav")
var destroy_sound = preload("res://Audio/SoundEffects/Misc/KettleShardDestroySound.wav")

var active: bool = true

var pitch = 1.0

signal shard_destroyed(shard)

func _ready() -> void:
	var audio_data = AudioData.new(appear_sound, global_position)
	audio_data.pitch = pitch
	audio_data.max_distance = 1200
	AudioManager.play_sound(audio_data)

func _on_health_manager_entity_killed() -> void:
	if active:
		shard_destroyed.emit(self)
		active = false
		
		play("destroy")
		
		var audio_data = AudioData.new(destroy_sound, global_position)
		audio_data.pitch = pitch
		audio_data.volume = 6.0
		audio_data.max_distance = 3000
		AudioManager.play_sound(audio_data)
		
		await get_tree().create_timer(0.5).timeout
		
		queue_free()
