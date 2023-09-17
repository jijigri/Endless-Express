extends AudioStreamPlayer2D

@export var gameplay_tracks: Array[AudioStream]

func _ready() -> void:
	GameEvents.biome_changed.connect(_on_biome_changed)
	GameEvents.player_killed.connect(stop_music)

func _on_biome_changed(biome: BiomeData) -> void:
	pitch_scale = 1.0
	AudioServer.set_bus_effect_enabled(2, 0, false)
	change_music(biome.music)

func change_music(music: AudioStream) -> void:
	stream = music

func start_gameplay_music():
	play()

func stop_music():
	stop()

func on_danger_state_start():
	muffle_sound(0.8, 2)
	return
	var tween = create_tween()
	tween.tween_property(self, "pitch_scale", 1.2, 0.2)
	tween.play()

func on_danger_state_end():
	return
	muffle_sound(0.5)
	var tween = create_tween()
	tween.tween_property(self, "pitch_scale", 1.0, 0.5)
	tween.play()

func muffle_sound(time: float, bus: int = 0):
	AudioServer.set_bus_effect_enabled(bus, 0, true)
	var effect = AudioServer.get_bus_effect(bus, 0)
	effect.cutoff_hz = 200
	var tween = create_tween()
	tween.tween_property(effect, "cutoff_hz", 10000, time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
	tween.play()
	await tween.finished
	AudioServer.set_bus_effect_enabled(bus, 0, false)

func _on_finished() -> void:
	start_gameplay_music()
