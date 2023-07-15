class_name TargetSpawner
extends Node2D

@export var targets: EnemyPool
@export var number_of_targets_of_each_type: int = 5
@export var enabled: bool = true

@onready var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager")
@onready var arena_manager = get_tree().get_first_node_in_group("ArenaManager")

var current_enemies = {
}

func _ready() -> void:
	GameEvents.arena_cleared.connect(_on_arena_clear)
	
	initialize_dictionaries()

func initialize_dictionaries() -> void:
	
	for type in TargetEnemyData.TYPE.size():
		current_enemies[type] = 0

func spawn_enemies(arena: Node2D):
	if enabled == false:
		return
	
	var spawned_special: bool = false
	for type in TargetEnemyData.TYPE.size():
		for i in number_of_targets_of_each_type:
			var score = clamp(game_manager.current_score, 1.0, 99999.0)
			var random_chance: float = randf_range(0, (1.0 / score) * (50.0 * number_of_targets_of_each_type * TargetEnemyData.TYPE.size()))
			if random_chance <= 1 && random_chance >= 0 && !spawned_special && game_manager.current_score > 6:
				instantiate_enemy(type, true)
				spawned_special = true
			else:
				instantiate_enemy(type, false)

func respawn_enemies():
	if enabled == false:
		return
	
	for type in current_enemies.keys():
		var number_of_enemies = current_enemies[type]
		while number_of_enemies < number_of_targets_of_each_type:
			instantiate_enemy(type, false)
			number_of_enemies += 1

func instantiate_enemy(type: TargetEnemyData.TYPE, is_special: bool = false):
	var enemy_to_spawn = targets.enemy_pool[0].scene
	if is_special:
		if targets.enemy_pool.size() > 1:
			enemy_to_spawn = targets.enemy_pool[randf_range(1, targets.enemy_pool.size())].scene
	
	var pos: Vector2 = get_spawn_position()
	var instance: TargetStateMachine = Global.spawn_object(
		enemy_to_spawn, pos, 0, self
		)
	instance.initialize(self, type)
	current_enemies[type] += 1

func get_spawn_position():
	"""
	var rect = get_viewport_rect()
	rect.size = rect.size / 1.1
	var cam: Camera2D = CameraManager.current_camera
	rect.position = cam.get_screen_center_position()  - rect.size / 2
	var random_position = Helper.randv_rect(rect, 16)
	var map = get_world_2d().navigation_map
	var pos: Vector2 = NavigationServer2D.map_get_closest_point(map, random_position)
	"""
	if arena_manager == null:
		arena_manager = get_tree().get_first_node_in_group("ArenaManager")
	return arena_manager.get_random_position_on_navmesh()

func remove_target(type: TargetEnemyData.TYPE):
	if current_enemies.has(type):
		current_enemies[type] -= 1

func _on_arena_clear(arena: Arena):
	despawn_targets()

func despawn_targets():
	for i in get_children(false):
		i.queue_free()

func _on_respawn_timer_timeout() -> void:
	respawn_enemies()
