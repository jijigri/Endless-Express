extends ParallaxBackground

@export var scroll_speed: float = 1000

func _physics_process(delta: float) -> void:
	scroll_base_offset += Vector2(-1, 0) * scroll_speed * delta
