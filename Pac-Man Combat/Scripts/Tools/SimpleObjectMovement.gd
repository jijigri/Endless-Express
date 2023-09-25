@tool
class_name SimpleObjectMovement
extends Node2D

enum MOVE_TYPE {SIN, COS, CIRCLE}

@export var move_type: MOVE_TYPE
@export var speed: float = 1.0
@export var amplitude: float = 16.0
@export var auto_update: bool = false

@onready var initial_pos: Vector2 = global_position

var pos: Vector2 = Vector2()

var time: float = 0.0

func _process(delta: float) -> void:
	if Engine.is_editor_hint() == true:
		return
	
	if auto_update:
		update_pos(delta)

func update_pos(delta):
	if Engine.is_editor_hint() == true:
		return
	
	if move_type == MOVE_TYPE.SIN:
		pos = Vector2(0.0, sin(time * speed) * amplitude)
	elif move_type == MOVE_TYPE.COS:
		pos = Vector2(cos(time * speed) * amplitude, 0.0)
	elif move_type == MOVE_TYPE.CIRCLE:
		pos = Vector2(
			(cos(time * speed)) * amplitude,
			(sin(time * speed)) * amplitude,
			)
	
	time += delta

func get_pos() -> Vector2:
	if Engine.is_editor_hint() == true:
		return initial_pos
	
	return initial_pos + pos
