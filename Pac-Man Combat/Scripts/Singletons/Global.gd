extends Node2D

const GAME_SCENES = {
	"game": "res://Scenes/game.tscn",
	"main_menu": "res://Scenes/main_menu.tscn",
	"tutorial": "res://Scenes/tutorial.tscn",
	"train_station": "res://Scenes/UI/train_station.tscn"
}

var loading_screen = preload("res://Scenes/UI/loading_screen.tscn")
var current_scene

@onready var world = get_world_2d()

var current_player: PlayableCharacterData = preload("res://Resources/PlayableCharacters/Mia.tres")

var indicator_type_manager = SpawnIndicatorType.new()

var current_id: int = 0

var current_settings: SettingsData = SettingsData.new()

var debug_mode: bool = false
var pause_menu_enabled: bool = false

var version = "0.6.3"

func _ready():
	
	if current_scene == null:
		if get_tree().get_root().has_node("Game"):
			current_scene = get_tree().get_root().get_node("Game")
			spawn_object(current_player.scene, Vector2(), 0, current_scene)
		elif get_tree().get_root().has_node("MainMenu"):
			current_scene = get_tree().get_root().get_node("MainMenu")
		elif get_tree().get_root().has_node("Tutorial"):
			current_scene = get_tree().get_root().get_node("Tutorial")
		elif get_tree().get_root().has_node("TrainStation"):
			current_scene = get_tree().get_root().get_node("TrainStation")

func load_scene(next_scene: String):
	var loading_screen_instance = loading_screen.instantiate()
	get_tree().get_root().call_deferred("add_child", loading_screen_instance)
	
	var load_path: String
	if GAME_SCENES.has(next_scene):
		load_path = GAME_SCENES[next_scene]
	else:
		load_path = next_scene
	
	print_debug("Attempting to load ", load_path)
	
	var loader_next_scene

	if ResourceLoader.exists(load_path):
		loader_next_scene = ResourceLoader.load_threaded_request(load_path)
	
	if loader_next_scene == null:
		print_debug("Error: Attempting to load a non-existent file!")
		return
	
	current_scene.call_deferred("free")
	
	while true:
		var load_progress = []
		var load_status = ResourceLoader.load_threaded_get_status(load_path, load_progress)
		
		match load_status:
			0: #LOAD INVALID
				print_debug("Error: Cannot load, resource is invalid.")
				return
			1: #LOAD IN PROGRESS
				pass
			2: #LOAD FAILED
				print_debug("Error: Loading failed.")
				return
			3: #LOAD LOADED
				print_debug("SCENE LOADED SUCCESSFULLY")
				var next_scene_instance = ResourceLoader.load_threaded_get(load_path).instantiate()
				get_tree().get_root().call_deferred("add_child", next_scene_instance)
				
				loading_screen_instance.queue_free()
				current_scene = next_scene_instance
				
				if current_scene.name == "Game" && current_player != null:
					spawn_object(current_player.scene, Vector2(), 0, current_scene)
				
				return
		await get_tree().process_frame

func spawn_object(object, position: Vector2, rotation: float = 0, parent = null):
	var instance = object.instantiate()
	
	if parent == null:
		if current_scene != null:
			current_scene.add_child.call_deferred(instance)
		else:
			print_debug("No active scene found, adding to root")
			get_tree().root.add_child.call_deferred(instance)
	else:
		parent.add_child(instance)
	
	instance.position = position
	instance.rotation = rotation
	
	return instance

var enemy_spawn_sound = preload("res://Audio/SoundEffects/Effects/EnemySpawnSoundEffect.wav")

func spawn_with_indicator(indicator_type: SpawnIndicatorType.TYPE, object, pos: Vector2, rotation: float = 0, parent = null, time: float = 1.25, callable: Callable = Callable()):
	var indicator_scene: PackedScene = indicator_type_manager.scene_from_type(indicator_type)
	spawn_object(indicator_scene, pos, rotation, parent)
	await get_tree().create_timer(time).timeout
	var instance = spawn_object(object, pos, rotation, parent)
	
	var audio_data = AudioData.new(enemy_spawn_sound, pos)
	audio_data.volume = -10.0
	audio_data.max_distance = 1200.0
	AudioManager.play_sound(audio_data)
	
	GameEvents.enemy_spawned.emit()
	
	if callable != Callable():
		callable.call(instance)

func spawn_chaser(indicator_type: SpawnIndicatorType.TYPE, object, pos: Vector2, rotation: float = 0, parent = null, level: int = 0):
	var indicator_scene: PackedScene = indicator_type_manager.scene_from_type(indicator_type)
	spawn_object(indicator_scene, pos, rotation, parent)
	await get_tree().create_timer(1.25).timeout
	var instance = spawn_object(object, pos, rotation, parent)
	if instance.is_in_group("Chasers"):
		instance.level = level
	
	var audio_data = AudioData.new(enemy_spawn_sound, pos)
	audio_data.volume = -10.0
	audio_data.max_distance = 1200.0
	AudioManager.play_sound(audio_data)
	
	GameEvents.enemy_spawned.emit()

func swap_color(old_colors: Array, new_colors: Array, mat: Material):
	
	#mat.set_shader_parameter("OLD_COLOR1", Color("fabf79"))
	#mat.set_shader_parameter("NEW_COLOR1", Color.RED)

	for i in old_colors.size():
		match i:
			0:
				mat.set_shader_parameter("OLD_COLOR1", old_colors[i])
				mat.set_shader_parameter("NEW_COLOR1", new_colors[i])
			1:
				mat.set_shader_parameter("OLD_COLOR2", old_colors[i])
				mat.set_shader_parameter("NEW_COLOR2", new_colors[i])
			2:
				mat.set_shader_parameter("OLD_COLOR3", old_colors[i])
				mat.set_shader_parameter("NEW_COLOR3", new_colors[i])
			3:
				mat.set_shader_parameter("OLD_COLOR4", old_colors[i])
				mat.set_shader_parameter("NEW_COLOR4", new_colors[i])
	
func get_point_before_collision(origin, target) -> Vector2:
	var space_state = world.direct_space_state
	var query = PhysicsRayQueryParameters2D.create(origin, target, 4)
	var result = space_state.intersect_ray(query)
	if result:
		return result.position
	else:
		return target

func is_visible_from(origin, target) -> bool:
	var space_state = world.direct_space_state
	var query = PhysicsRayQueryParameters2D.create(origin, target, 4)
	var result = space_state.intersect_ray(query)
	if result:
		return false
	else:
		return true

func get_unique_id() -> int:
	current_id += 1
	if current_id >= 9223372036854775801:
		current_id = 1
	return current_id

func wobble(object, from: Vector2, value: float, strength: float = 4.0):
	object.position = from + (Vector2(randf_range(-value, value), randf_range(-value, value)) * strength)

func wobble_offset(object, value: float, strength: float = 4.0):
	object.offset = Vector2.ZERO + (Vector2.ONE * (value * strength))

func play_popup_effect(target, center_pivot: bool = false, time = 0.2) -> Tween:
	if center_pivot:
		target.pivot_offset = target.size / 2
	target.scale = Vector2()
	var tween = create_tween()
	tween.tween_property(target, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.play()
	return tween

const player_data_path: String = "user://playerdata.tres"
func load_player_data():
	if ResourceLoader.exists(player_data_path):
		return load(player_data_path)
	else:
		return PlayerSaveData.new()

func save_player_data(data):
	ResourceSaver.save(data, player_data_path)
