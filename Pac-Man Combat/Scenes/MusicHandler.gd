extends AudioStreamPlayer2D

@export var gameplay_tracks: Array[AudioStream]

func start_gameplay_music():
	stream = gameplay_tracks.pick_random()
	play()

func stop_music():
	stop()


func _on_finished() -> void:
	start_gameplay_music()
