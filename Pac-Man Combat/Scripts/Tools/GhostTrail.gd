class_name GhostTrail
extends Node2D

@export var time_between_ghosts: float = 0.1
@export var frames_between_ghosts: int = 0
@export var color: Color
@export var fade_to_color: bool = true
@export var ghost_lifetime: float = 0.1
@export var texture: Texture2D
@export var enabled: bool = true:
	set(value):
		if !Engine.is_editor_hint():
			if value == true:
				if enabled == false:
					enable()
			else:
				if enabled == true:
					disable()
		enabled = value


@onready var timer: Timer = $Timer

var ghost_scene = preload("res://Scenes/Effects/sprite_ghost.tscn")

func enable():
	if frames_between_ghosts <= 0:
		timer.start()

func disable():
	if frames_between_ghosts <= 0:
		timer.stop()

func _ready() -> void:
	if frames_between_ghosts <= 0:
		timer.wait_time = time_between_ghosts
		if enabled:
			timer.start()

func _process(delta: float) -> void:
	if frames_between_ghosts > 0:
		if enabled:
			if Engine.get_process_frames() % frames_between_ghosts == 0:
				spawn_ghost()

func spawn_ghost():
	if texture != null:
		var ghost = Global.spawn_object(ghost_scene, global_position)
		ghost.set_color(color)
		ghost.lifetime = ghost_lifetime
		ghost.texture = texture
		ghost.scale = scale
		if !fade_to_color:
			ghost.material.set_shader_parameter("strength", 1.0)

func _on_timer_timeout() -> void:
	print_debug("timeout")
	if enabled:
		spawn_ghost()
