extends ChaserStateMachine

@onready var appear_effect: AnimatedSprite2D = $AppearEffect

func _ready() -> void:
	super._ready()
	
	sprite.sprite_frames = player.sprite.sprite_frames
	sprite.transform = player.sprite.transform
	sprite.offset = player.sprite.offset
	
	make_appear()

func _on_player_ghost_movement_received_player_data(data: PlayerData) -> void:
	if sprite != null:
		var animation : String = data.animation
		var frame : int = data.frame
		sprite.animation = animation
		sprite.frame = frame
	pass


func _on_status_effects_manager_effect_removed(effect) -> void:
	if effect == "freeze":
		make_appear()
		

func kill() -> void:

	PlayerDataQueue.remove_ghost()
	
	super.kill()

func make_appear():
	for i in attacks:
			i.active = false
	sprite.visible = false
	appear_effect.play("appear")
	appear_effect.frame = 0
	
	var data = AudioData.new(preload("res://Audio/SoundEffects/Enemies/Ghost/GhostAppearSound.wav"), global_position)
	data.max_distance = 2600
	AudioManager.play_sound(data)

func _on_appear_effect_animation_finished() -> void:
	if appear_effect.animation == "appear":
		for i in attacks:
			i.active = true
		sprite.visible = true
		appear_effect.play("default")


func _on_appear_effect_animation_looped() -> void:
	if appear_effect.animation == "default":
		await get_tree().create_timer(0.1).timeout
		attacks[0].check_damage()
		var data = AudioData.new(preload("res://Audio/SoundEffects/Enemies/Ghost/GhostPulseSound.wav"), global_position)
		data.max_distance = 300
		data.attenuation = 1.2
		data.pitch = randf_range(0.8, 1.2)
		AudioManager.play_sound(data)
