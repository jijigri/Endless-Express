extends AudioStreamPlayer2D

@export var gameplay_tracks: Array[AudioStream]

func _ready() -> void:
	GameEvents.biome_changed.connect(_on_biome_changed)
	GameEvents.player_killed.connect(stop_music)

func _on_biome_changed(biome: BiomeData) -> void:
	change_music(biome.music)

func change_music(music: AudioStream) -> void:
	stream = music

func start_gameplay_music():
	play()

func stop_music():
	stop()


func _on_finished() -> void:
	start_gameplay_music()
