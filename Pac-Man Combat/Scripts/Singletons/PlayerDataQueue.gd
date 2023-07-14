extends Node

var player

var data_update_time: float = 0.01

var data_queue = []
var max_queue_size = 500
var frames_between_ghosts = 18

var current_number_of_ghosts: int = 0

var recording: bool = true

func reset():
	data_queue.clear()
	current_number_of_ghosts = 0

func add_ghost():
	current_number_of_ghosts += 1
	if max_queue_size / current_number_of_ghosts < frames_between_ghosts:
		max_queue_size += frames_between_ghosts

func remove_ghost():
	current_number_of_ghosts -= 1
	if current_number_of_ghosts > 0:
		if max_queue_size / current_number_of_ghosts > frames_between_ghosts:
			max_queue_size -= frames_between_ghosts

func record_player_data():
	await get_tree().process_frame
	recording = true 
	player = get_tree().get_first_node_in_group("Player")
	for i in max_queue_size:
		var player_data: PlayerData = PlayerData.new(player.global_position, player.sprite.animation, player.sprite.frame)
		add_data(player_data)
	
	while recording:
		if player != null:
			var player_data = PlayerData.new(player.global_position, player.sprite.animation, player.sprite.frame)
			add_data(player_data)
			await get_tree().create_timer(data_update_time, true, true).timeout

func stop_recording():
	recording = false

func add_data(data: PlayerData) -> void:
	if data_queue.size() > max_queue_size:
		dequeue_first()
	data_queue.push_back(data)

func dequeue_first() -> void:
	data_queue.pop_front()

func get_data(index: int = 0) -> PlayerData:
	if data_queue.size() > index:
		return data_queue[index]
	else: return null
