extends Area2D

var respawn_position: Vector2 = Vector2(720, -352 - 4)

func _process(delta: float) -> void:
	if get_overlapping_areas().size() > 0:
		for area in get_overlapping_areas():
			if area is Hurtbox:
				var player = get_tree().get_first_node_in_group("Player")
				if !player.health_manager.is_rolling:

					player.global_position = respawn_position
					
					var audio_data = AudioData.new(preload("res://Audio/SoundEffects/Player/PlayerHit.wav"), player.global_position)
					AudioManager.play_sound(audio_data)
					
					player.movement_ability.current_cooldown = 0
