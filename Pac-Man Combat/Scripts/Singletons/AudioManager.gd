extends Node2D

@export var stream_players_amount: int = 128

var players_parent: Node2D

const AUDIO_PATH: String = "res://Audio/SoundEffects/"

var limited_players = {}

func _ready() -> void:
	
	var instance = Node2D.new()
	instance.position = global_position
	instance.name = "parent"
	add_child(instance)
	players_parent = instance
	
	for i in stream_players_amount:
		var audio_stream_player = AudioStreamPlayer2D.new()
		audio_stream_player.position = global_position
		audio_stream_player.name = "audio_stream_player" + str(i)
		audio_stream_player.bus = "FX"
		players_parent.add_child(audio_stream_player)
		

func play_sound(streamData: AudioData):
	for audio_stream_player in players_parent.get_children():
		if audio_stream_player.playing == false:
			start_on_stream(audio_stream_player, streamData)
			return
	
	print("AudioManager: Not enough audio source to play sound, overriding!")
	start_on_stream(players_parent.get_child(0), streamData)

func play_delayed(steam_data: AudioData, time: float):
	await get_tree().create_timer(time).timeout
	play_sound(steam_data)

func play_in_player(stream_data: AudioData, name: String, limit: int, override: bool = false):
	
	if !limited_players.has(name):
		for i in limit:
			limited_players[name] = []
			limited_players[name].append(add_player(self, name))
	else:
		if limited_players[name].size() < limit:
			for i in limit - limited_players[name].size():
				limited_players[name].append(add_player(self, name))
	
	for audio_stream_player in limited_players[name]:
		if audio_stream_player.playing == false:
			start_on_stream(audio_stream_player, stream_data)
			return
	
	if override:
		start_on_stream(limited_players[name][0], stream_data)

func add_player(parent = self, name = self.name) -> AudioStreamPlayer2D:
	var audio_stream_player = AudioStreamPlayer2D.new()
	audio_stream_player.position = global_position
	audio_stream_player.name = name
	audio_stream_player.bus = "FX"
	parent.add_child(audio_stream_player)
	return audio_stream_player

func start_on_stream(stream_player: AudioStreamPlayer2D, stream_data: AudioData):
	stream_player.stream = stream_data.stream
	stream_player.position = stream_data.position
	stream_player.volume_db = stream_data.volume
	stream_player.pitch_scale = stream_data.pitch
	stream_player.max_distance = stream_data.max_distance
	stream_player.attenuation = stream_data.attenuation
	stream_player.play()
