class_name CooldownCircle
extends Node2D

@onready var progress: TextureProgressBar = $Progress

var current_cooldown = 0.0
var active: bool = false

func set_cooldown(time: float):
	current_cooldown = time
	progress.max_value = current_cooldown
	progress.value = current_cooldown
	active = true

func _process(delta: float) -> void:
	if !active:
		return
	
	if current_cooldown > 0.0:
		current_cooldown -= delta
		progress.value = current_cooldown
	else:
		active = false
		queue_free()
