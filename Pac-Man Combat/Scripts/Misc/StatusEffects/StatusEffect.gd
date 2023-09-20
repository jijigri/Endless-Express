class_name StatusEffect
extends Node2D

enum TYPE {BUFF, NERF}

@export var sound_effect: AudioStream
@export var type: TYPE

var timer: Timer
var entity_owner
var manager

var effect_name

var active: bool = false

func initialize(manager, entity_owner, effect_name: String, time: float):
	if entity_owner == null:
		return
	
	self.entity_owner = entity_owner
	self.manager = manager
	
	self.effect_name = effect_name
	
	timer = $Timer
	timer.wait_time = time
	timer.start(time)
	active = true
	_initiated()

func _initiated():
	play_sound_effect()

func play_sound_effect():
	if sound_effect != null:
		var audio_data = AudioData.new(sound_effect, global_position)
		audio_data.max_distance = 1000
		AudioManager.play_in_player(audio_data, effect_name, 3)

func _on_timer_timeout() -> void:
	disable_effect()

func disable_effect(called_from_manager: bool = false):
	active = false
	if !called_from_manager:
		manager.remove_effect(effect_name)
	await get_tree().create_timer(1.0).timeout
	queue_free()

func destroy():
	queue_free()
