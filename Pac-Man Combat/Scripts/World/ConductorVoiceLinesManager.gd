@tool
extends AudioStreamPlayer

@export var refresh_lines: bool = false : set = set_refresh_lines
@export var test_lines: Array

@onready var game_manager = get_tree().get_first_node_in_group("GameManager")
@onready var arena_manager = get_tree().get_first_node_in_group("ArenaManager")
@onready var start_sound = $StartSound
@onready var static_sound = $Static
@onready var subtitle = $Subtitles/SubtitleText

var turn_on_sound = preload("res://Audio/SoundEffects/Misc/InterphoneTurnOnSound.wav")

var curr_index: int = 0

var cancelled: bool = false

func set_refresh_lines(value):
	set_files_from_folder()
	refresh_lines = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	GameEvents.arena_cleared.connect(_on_arena_cleared)
	GameEvents.arena_exited.connect(_on_arena_exited)
	subtitle.visible = false

func set_files_from_folder():
	if Engine.is_editor_hint() == false:
		return
	
	test_lines.clear()
	
	var path: String = "res://Audio/VoiceLines/"
	var dir = get_file(path)
	
	if !dir:
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir() == false:
			continue
		
		var level = get_file(path + "/" + file_name)
		var voice_line_data = VoiceLineData.new()

		var level_file = level.get_next()
		
		while level_file != "":
			if level.current_is_dir() == false:
				continue
			
			#If current folder is "Generic"
			if level_file == "Generic":
				
				add_files_to_data(voice_line_data, path + "/" + file_name + "/" + level_file, 0)
			
			#If current folder is "Intros"
			elif level_file == "Intros":
				
				add_files_to_data(voice_line_data, path + "/" + file_name + "/" + level_file, 1)
			
			level_file = level.get_next()
		
		
		test_lines.append(voice_line_data)
		
		file_name = dir.get_next()

func get_file(path):
	var file = DirAccess.open(path)
	file.list_dir_begin()
	return file

func add_files_to_data(voice_line_data, path, type: int = 0):
	var file = get_file(path)
								
	var file_name = file.get_next()
	while file_name != "":
		if !file.current_is_dir() && file_name.ends_with(".ogg"):
			if type == 0:
				var d : Dictionary
				voice_line_data.generic[load(path + "/" + file_name)] = ""
			elif type == 1:
				voice_line_data.intros[load(path + "/" + file_name)] = ""
		file_name = file.get_next()

func _on_arena_cleared(arena: Arena):
	if Engine.is_editor_hint():
		return
	
	cancelled = false
	
	var play_audio: bool = false
	
	var rand_change = randf_range(0.0, 100.0)
	if rand_change >= 50.0:
		play_audio = true
	
	if fmod(game_manager.old_score, arena_manager.biome_change_step) == 0:
		play_audio = true
	
	if !play_audio:
		return
	
	await get_tree().create_timer(0.8).timeout
	
	if cancelled:
		return
	
	start_sound.stream = preload("res://Audio/SoundEffects/Misc/InterphoneTurnOnSound.wav")
	start_sound.play()
	
	static_sound.volume_db = -30.0
	var tween = create_tween()
	tween.tween_property(static_sound, "volume_db", -20.0, 0.5)
	static_sound.play()
	
	await get_tree().create_timer(0.5).timeout
	
	if cancelled:
		return
	
	stream = get_line()
	play()
	
	curr_index += 1

func _on_finished() -> void:
	if Engine.is_editor_hint():
		return
	
	subtitle.visible = false
	
	start_sound.stream = preload("res://Audio/SoundEffects/Misc/InterphoneTurnOffSound.wav")
	start_sound.play()
	
	var tween = create_tween()
	tween.tween_property(static_sound, "volume_db", -30.0, 0.2)
	tween.tween_callback(static_sound.stop)
	
	return
	if stream == turn_on_sound:
		stream = get_line()
		play()

func get_line() -> AudioStream:
	var current_line_data = test_lines[0]
	
	if fmod(game_manager.old_score, arena_manager.biome_change_step) == 0:
		#Get intro
		var key = get_random_dict_key(current_line_data.intros)
		var subtitle = current_line_data.intros[key]
		set_subtitle(key, subtitle)
		return key
	else:
		#Get generic or chain
		var key = get_random_dict_key(current_line_data.generic)
		var subtitle = current_line_data.generic[key]
		set_subtitle(key, subtitle)
		return key

func set_subtitle(stream, text):
	var time = stream.get_length() * 0.75
	subtitle.text = "Conductor: " + text
	subtitle.visible = true
	
	subtitle.visible_characters = 10
	var tween = create_tween()
	tween.tween_property(subtitle, "visible_ratio", 1.0, time)
	tween.play()

func _on_arena_exited(arena: Arena):
	if playing:
		stop()
		start_sound.stop()
		cancelled = true
		_on_finished()

func get_random_dict_key(dict):

	var a = dict.keys()

	a = a[randi() % a.size()]

	return a
