extends Area2D

@export var damage: float = 20.0
@export var time_to_set_spikes: float = 0.5
@export var time_before_retraction: float = 2.0

@onready var base_sprite = $BaseSprite
@onready var spikes_sprite = $SpikesSprite
@onready var cooldown_timer: Timer = $CooldownTimer

var cooldown: float = 2.0

var hits = []

var spikes_out: bool = false
var can_set_spikes: bool = true

func set_spikes():
	can_set_spikes = false
	on_spikes_activated()
	
	hits.clear()
	
	await get_tree().create_timer(0.5).timeout
	spikes_out = true
	spikes_sprite.play("open")
	
	var audio_data = AudioData.new(preload("res://Audio/SoundEffects/ArenaProps/RetractingSpikes/RetractingSpikesOpen.wav"), global_position)
	AudioManager.play_sound(audio_data)
	
	await get_tree().create_timer(time_before_retraction).timeout
	if spikes_out:
		retract_spikes()

func on_spikes_activated():
	spikes_sprite.play("activated")
	base_sprite.play("activated")
	
	var audio_data = AudioData.new(preload("res://Audio/SoundEffects/ArenaProps/RetractingSpikes/RetractingSpikesActivated.wav"), global_position)
	AudioManager.play_sound(audio_data)

func _process(_delta: float) -> void:
	if spikes_out:
		var areas = get_overlapping_areas()
		if areas.size() < 1: return
		for hit in areas:
			if hit.is_in_group("Hurtbox"):
				if hit.has_method("receive_hit"):
					if !hits.has(hit):
						if hit.has_meta("isPlayer"):
							var damageData = DamageData.new(damage, global_position, Vector2())
							damageData.source = self
							hit.receive_hit(damageData)
							retract_spikes()
							get_tree().call_group("RetractingSpikes", "retract_spikes")
						else:
							var damageData = DamageData.new(0.0, global_position, Vector2(), 0.5)
							damageData.source = self
							hit.receive_hit(damageData)
						hits.append(hit)
		return
	else:
		if can_set_spikes == false:
			return
		
		var bodies = get_overlapping_bodies()
		if bodies.size() < 1: return
		for hit in bodies:
			if hit is Player:
				set_spikes()

func retract_spikes():
	if spikes_out:
		spikes_out = false
		
		cooldown_timer.wait_time = cooldown
		cooldown_timer.start()
		
		spikes_sprite.play("close")
		base_sprite.play("default")
		
		var audio_data = AudioData.new(preload("res://Audio/SoundEffects/ArenaProps/RetractingSpikes/RetractingSpikesRetract.wav"), global_position)
		audio_data.max_distance = 640
		AudioManager.play_in_player(audio_data, "spikes_retract", 10)


func _on_cooldown_timer_timeout() -> void:
	can_set_spikes = true
	spikes_sprite.play("default")
	var audio_data = AudioData.new(preload("res://Audio/SoundEffects/ArenaProps/RetractingSpikes/RetractingSpikesReady.wav"), global_position)
	audio_data.max_distance = 350
	AudioManager.play_in_player(audio_data, "spikes_ready", 10)
