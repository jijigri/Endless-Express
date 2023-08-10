class_name ArenaManager
extends Node2D

@export var solo_arena: PackedScene = null
@export var arena_pool: Array[PackedScene]
@export var biome_pool: Array[BiomeData]
@export var biome_change_step: int = 10

var current_biome: BiomeData
var used_biomes = []

@onready var world = get_world_2d()

@onready var game_manager = get_tree().get_first_node_in_group("GameManager")

var current_arena: Arena

func _ready() -> void:
	
	change_current_biome()
	
	spawn_arena()
	GameEvents.arena_exited.connect(_on_arena_exited)


func _on_arena_exited(arena: Arena):
	print_debug("Changing current Arena from " + current_arena.name)
	
	#SceneTransitions.fade_in_out(1.0, 0.2)
	
	var transition = Global.spawn_object(preload("res://Scenes/UI/car_transition_screen.tscn"), Vector2(), 0, HUD)
	transition.initialize(game_manager.old_score, game_manager.current_score)
	await transition.transition_complete
	
	#dawait get_tree().create_timer(0.5).timeout
	
	change_current_arena()

func change_current_arena() -> void:
	delete_current_arena()
	spawn_arena()

func delete_current_arena() -> void:
	current_arena.queue_free()

func spawn_arena() -> void:
	var arena: PackedScene
	if solo_arena == null:
		var index: int = get_random_arena()
		arena = current_biome.arenas[index]
	else:
		arena = solo_arena
	current_arena = Global.spawn_object(arena, global_position)

func get_random_arena() -> int:
	
	try_change_biome()
	
	var random_arena_index: int = randi_range(0, current_biome.arenas.size() - 1)
	return random_arena_index

func try_change_biome():
	var diff = game_manager.current_score - game_manager.old_score
	for i in diff:
		if (game_manager.current_score - i) % biome_change_step == 0:
			change_current_biome()
			return

func change_current_biome():
	var current_score = game_manager.current_score
	
	if used_biomes.size() >= biome_pool.size():
		current_biome = biome_pool[randf_range(0, biome_pool.size() - 1)]
		print_debug("Ran through all possible biomes, returning a random one")
		return
	
	for i in biome_pool:
		if !used_biomes.has(i):
			if i.min_level <= clamp(current_score, 0, 99999):
				current_biome = i
				used_biomes.append(i)
				GameEvents.biome_changed.emit(i)

func get_random_position_on_navmesh() -> Vector2:
	randomize()
	var arena_rect: Rect2i = current_arena.navigation_map.get_used_rect()

	var rect_pos: Vector2 = to_global(current_arena.navigation_map.map_to_local(arena_rect.position))
	var rect_end: Vector2 = to_global(current_arena.navigation_map.map_to_local(arena_rect.end))

	var random_position = Vector2(
		randf_range(rect_pos.x, rect_end.x),
		randf_range(rect_pos.y, rect_end.y)
		)

	var map = world.navigation_map
	var pos: Vector2 = NavigationServer2D.map_get_closest_point(map, random_position)
	
	return pos
