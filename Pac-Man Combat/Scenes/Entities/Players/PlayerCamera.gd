extends Camera2D

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
