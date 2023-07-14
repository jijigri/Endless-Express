class_name ChaserSpawner
extends Node2D

@export var chasers: EnemyPool
@export var intensity_curve_min: Curve
@export var intensity_curve_max: Curve
@export var curve_sample_size: int
@export var enabled: bool = true

@onready var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager")
@onready var arena_manager: ArenaManager = get_tree().get_first_node_in_group("ArenaManager")

var weights: Array[float] = []

var current_number_of_enemies: int = 0

var initial_time_to_reatreat = 0
var retreat_duration = 1
var time_left_to_retreat = 0
var retreat_time_modifier = 1

func _ready() -> void:
	GameEvents.player_damaged.connect(on_player_damaged)
	weights.resize(chasers.enemy_pool.size())

func _process(delta: float) -> void:
	if time_left_to_retreat > 0:
		time_left_to_retreat -= delta * retreat_time_modifier
		retreat_time_modifier += delta * 0.5
	else:
		if current_number_of_enemies > 2:
			start_retreat()

func reset_spawn_weights() -> void:
	var total_weight = 0
	
	for i in chasers.enemy_pool.size():
		weights[i] = chasers.enemy_pool[i].get_weight()
		total_weight += weights[i]
	
	if total_weight == 0:
		print_debug("Can't reset weights as total weight is 0")
		return
	
	for i in weights.size():
		weights[i] = weights[i] / total_weight

func spawn_enemies(arena: Node2D) -> void:
	if enabled == false:
		return
	
	var intensity: float = get_intensity()
	
	print_debug("intensity: ", intensity)
	
	if intensity < 0:
		return
	
	reset_spawn_weights()
	
	var enemies_to_spawn: Array[PackedScene] = get_enemies_to_spawn(intensity, game_manager.current_score)
	
	for i in enemies_to_spawn:
		var pos: Vector2 = arena_manager.get_random_position_on_navmesh()
		Global.spawn_with_indicator(SpawnIndicatorType.TYPE.DANGER, i, pos, 0, get_parent())
	
	current_number_of_enemies = enemies_to_spawn.size()
	
	set_retreat_times(intensity)

func get_intensity() -> float:
	var score: int = game_manager.current_score
	
	if score < 0:
		return -1
	
	var intensity_min = intensity_curve_min.sample(
		(score % curve_sample_size) / float(curve_sample_size)
		)
	var intensity_max = intensity_curve_max.sample(
		(score % curve_sample_size) / float(curve_sample_size)
		)
	
	var add_score = floori(score / curve_sample_size) * curve_sample_size
	
	return randf_range(intensity_min, intensity_max) + 1 + add_score
	

func get_enemies_to_spawn(intensity: int, score: int) -> Array[PackedScene]:
	var current_intensity = intensity
	var enemies_to_spawn: Array[PackedScene]
	
	var error: int = 0
	while current_intensity > 0:
		
		#Pick a random enemy from the pool
		var test_enemy: ChaserEnemyData = get_weighted_enemy()
		#Check if the enemy can fit based on the intensity level
		if test_enemy.level <= current_intensity && test_enemy.min_wave_to_spawn_in <= score:
			current_intensity -= test_enemy.level
			enemies_to_spawn.append(test_enemy.scene)
		
		error += 1
		if error > 500:
			print_debug("EnemySpawner: ERROR IN THE INTENSITY LOOP, WAY TOO MANY ITERATIONS")
			break
	
	return enemies_to_spawn

func get_weighted_enemy():
	randomize()
	var value = randf()
	for i in weights.size():
			if value < weights[i]:
				return chasers.enemy_pool[i]
			
			value -= weights[i]
	
	print_debug("Uh oooh, problem getting weighted enemy")
	return chasers.enemy_pool[randi_range(0, chasers.enemy_pool.size() - 1)]

func set_retreat_times(intensity: int):
	retreat_duration = clamp(float(intensity) / 5, 0.1, 6.0)
	
	initial_time_to_reatreat = 40.0
	time_left_to_retreat = initial_time_to_reatreat + randf_range(0, initial_time_to_reatreat / 2)
	retreat_time_modifier = 1.0

func start_retreat():
	get_tree().call_group("Chasers", "retreat", retreat_duration)
	time_left_to_retreat = (initial_time_to_reatreat + randf_range(0, initial_time_to_reatreat / 2)) + (retreat_duration + (retreat_duration * 0.5))
	retreat_time_modifier = 1.0

func remove_chaser():
	current_number_of_enemies -= 1
	if current_number_of_enemies <= 0:
		arena_manager.current_arena.on_arena_clear()

func get_spawn_position() -> Vector2:
	randomize()
	var random_position = Vector2(randf_range(-800, 800), randf_range(-800, 800))

	var map = get_world_2d().navigation_map
	var pos: Vector2 = NavigationServer2D.map_get_closest_point(map, random_position)
	
	#print_debug("Random: ", random_position, " and position: ", pos)
	
	return pos

func on_player_damaged(current_health: float, max_health: float, value: float):
	retreat_time_modifier = 1.0
