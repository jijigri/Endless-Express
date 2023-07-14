class_name DestroyAfterTime
extends GPUParticles2D

@export var time: float = 1.0

func _ready() -> void:
	await get_tree().create_timer(time).timeout
	queue_free()
