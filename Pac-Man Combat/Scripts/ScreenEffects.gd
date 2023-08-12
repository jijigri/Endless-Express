extends Node2D

@export var damage_color: Color = Color.DARK_RED
@export var heal_color: Color = Color.MEDIUM_SPRING_GREEN
@export var energy_color: Color = Color.ORANGE

@export var danger_color_start: Color = Color.RED
@export var danger_color_end: Color = Color.DARK_RED


var is_in_danger: bool = false
var time: float = 0

var tilemap: TileMap

func _ready() -> void:
	GameEvents.arena_entered.connect(update_tilemap)

func _process(delta: float) -> void:
	if tilemap == null:
		return
	
	if is_in_danger:
		var value = (sin(time * 8) + 1.0) * 0.5
		
		var color = lerp(danger_color_start, danger_color_end, value)
		tilemap.set_layer_modulate(1, color)
		
		time += delta
	else:
		tilemap.set_layer_modulate(1, Color.WHITE)

func update_tilemap(arena: Arena):
	tilemap = arena.level_map

func damage_effect(time: float = 0.1):
	start_tint(damage_color, time)

func heal_effect(time: float = 0.1):
	start_tint(heal_color, time)

func energy_effect(time: float = 0.1):
	start_tint(energy_color, time)

func debug_effect(time: float = 0.1):
	start_tint(Color.BLACK, time)

func start_tint(color, time):
	if tilemap == null:
		tilemap = get_tree().get_first_node_in_group("ArenaManager").current_arena.level_map
		print_debug("Couldn't find the tilemap, searching for it again")
	
	set_modulate_color(color)
	
	var tween = create_tween()
	
	var end_color: Color = Color.WHITE
	if is_in_danger:
		end_color = danger_color_start
		time = 0
	
	tween.tween_method(set_modulate_color, color, end_color, time)
	tween.tween_callback(tint_end)
	tween.play()

func tint_end():
	if !is_in_danger:
		set_modulate_color(Color.WHITE)

func set_modulate_color(value: Color):
	if tilemap == null:
		var arena_manager = get_tree().get_first_node_in_group("ArenaManager")
		if arena_manager == null:
			return
		
		tilemap = get_tree().get_first_node_in_group("ArenaManager").current_arena.level_map
		print_debug("Couldn't find the tilemap, searching for it again")
	
	tilemap.set_layer_modulate(1, value)
