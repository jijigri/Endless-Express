extends EntityMovement

signal received_player_data(data: PlayerData)

func _ready() -> void:
	PlayerDataQueue.current_number_of_ghosts += 1
	set_pos()

func set_pos():
	var rand_index = PlayerDataQueue.max_queue_size - ((PlayerDataQueue.current_number_of_ghosts) * PlayerDataQueue.frames_between_ghosts)
	while true:
		if speed_modifier >= 1:
			var data = PlayerDataQueue.get_data(rand_index)
			if data != null:
				owner.global_position = data.position
				received_player_data.emit(data)
		await get_tree().create_timer(PlayerDataQueue.data_update_time, true, true).timeout
