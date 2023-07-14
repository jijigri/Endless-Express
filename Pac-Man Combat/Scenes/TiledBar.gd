@tool
class_name TiledBar
extends NinePatchRect

@export var value: float = 100.0
@export var max_value: float = 50.0

@onready var background = $Background

var is_full: bool = false

func _ready() -> void:
	region_rect.position.x = -1

func _process(delta: float) -> void:
	
	if background == null:
		background = $Background
	
	max_value = clamp(max_value, 0, 100000)
	value = clamp(value, 0, max_value)
	
	if value == max_value:
		if !is_full:
			on_full()
	else:
		if is_full:
			on_not_full()
	
	background.size.x = max_value
	size.x = value

func on_full():
	is_full = true
	region_rect.position.x = 9
	
	material.set_shader_parameter("flash_modifier", 1.0)
	
	var tween = create_tween()
	tween.tween_method(tween_flash, 1.0, 0, 0.3)
	

func on_not_full():
	is_full = false
	region_rect.position.x = -1

func tween_flash(value: float):
	material.set_shader_parameter("flash_modifier", value)
