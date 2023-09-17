@tool
extends Node2D

@export var targets: EnemyPool
@export var number_of_targets_of_each_type: int = 5
@export_range(16, 1024, 16, "or_greater") var width: int = 16:
	set(value):
		width = value
		size.x = value
		queue_redraw()

@export_range(16, 1024, 16, "or_greater") var height: int = 16:
	set(value):
		height = value
		size.y = value
		queue_redraw()

var size: Vector2 = Vector2(16, 16)
@export var enabled: bool = true

var current_enemies = {
}

func _ready() -> void:
	queue_redraw()
	if Engine.is_editor_hint():
		return
	
	initialize_dictionaries()

func initialize_dictionaries() -> void:
	for type in TargetEnemyData.TYPE.size():
		current_enemies[type] = 0

func spawn_enemies(arena: Node2D):
	if Engine.is_editor_hint():
		return
	
	if enabled == false:
		return
	
	var spawned_special: bool = false
	for type in TargetEnemyData.TYPE.size():
		for i in number_of_targets_of_each_type:
			instantiate_enemy(type)

func respawn_enemies():
	if Engine.is_editor_hint():
		return
	
	if enabled == false:
		return
	
	for type in current_enemies.keys():
		var number_of_enemies = current_enemies[type]
		while number_of_enemies < number_of_targets_of_each_type:
			instantiate_enemy(type)
			number_of_enemies += 1

func instantiate_enemy(type: TargetEnemyData.TYPE):
	if Engine.is_editor_hint():
		return
	
	var enemy_to_spawn = targets.enemy_pool[0].scene
	
	var pos: Vector2 = get_spawn_position()
	var instance: TargetStateMachine = Global.spawn_object(
		enemy_to_spawn, pos, 0, self
		)
	instance.initialize(self, type)
	current_enemies[type] += 1

func get_spawn_position():
	var rect = Rect2()
	rect.position =  -(size / 2)
	rect.size = size
	
	var pos: Vector2
	pos.x = randf_range(rect.position.x, rect.end.x)
	pos.y = randf_range(rect.position.y, rect.end.y)
	
	return pos

func remove_target(type: TargetEnemyData.TYPE):
	if Engine.is_editor_hint():
		return
	
	if current_enemies.has(type):
		current_enemies[type] -= 1

func _on_arena_clear(arena: Arena):
	despawn_targets()

func despawn_targets():
	for i in get_children(false):
		i.queue_free()

func _on_respawn_timer_timeout() -> void:
	if Engine.is_editor_hint():
		return
	
	respawn_enemies()

func _draw() -> void:
	if Engine.is_editor_hint() == false:
		return
	
	var rect = Rect2()
	rect.position = -(size / 2)
	rect.size = size
	
	var color = Color.RED
	
	draw_rect(rect, color, false, 4.0)
	
	color.a = 0.2
	
	draw_rect(rect, color, true)
	
	
	
