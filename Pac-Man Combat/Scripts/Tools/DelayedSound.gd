extends AudioStreamPlayer2D

@export var time: float = 0.5

func _ready() -> void:
	await get_tree().create_timer(time).timeout
	play()
