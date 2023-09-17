extends Camera2D

@export var max_distance_from_player: float = 40.0
@export var camera_speed: float = 10.0

@onready var game_manager = get_tree().get_first_node_in_group("GameManager")

var player

func _ready() -> void:
	GameEvents.arena_entered.connect(_on_arena_entered)

func _on_arena_entered(arena: Arena):
	var tilemap = arena.get_node("Map/Level")
	#tilemap.get_used_rect().position
	var rect = tilemap.get_used_rect()
	var margin: float = 16 * 8
	limit_top = (rect.position.y * 16) + margin
	limit_bottom = (rect.end.y * 16) - margin
	limit_left = (rect.position.x * 16) + margin
	limit_right = (rect.end.x * 16) - margin

func initialize(player):
	self.player = player
	reparent.call_deferred(player.get_parent())

func _physics_process(delta: float) -> void:
	if player == null:
		return
	
	if game_manager != null:
		if game_manager.game_over:
			return
	if Global.pause_menu_enabled:
		return
	
	var mouse_pos: Vector2 = get_global_mouse_position()
	var player_pos: Vector2 = player.global_position
	
	var new_pos = get_camera_position(mouse_pos, player_pos)
	
	var speed_modifier = clamp(player.velocity.length() / 300, 1.0, 2.0)
	
	global_position = global_position.lerp(new_pos, delta * camera_speed * speed_modifier)

func get_camera_position(mouse_pos: Vector2, player_pos: Vector2) -> Vector2:
	var direction = mouse_pos - player_pos
	var length = clamp(pow(direction.length() / 2, 0.82), 0.0, max_distance_from_player)
	return player_pos + (direction.normalized() * length)
