class_name PackPickup
extends Pickup

@export var speed: float = 20.0

func _ready() -> void:
	super._ready()
	rotation_degrees = randf_range(0, 360)

func _on_magnet_body_entered(body: Node2D) -> void:
	return
	if magnet_target != null:
		return
	
	if body.is_in_group("Player"):
		magnet_target = body

func _process(delta: float) -> void:
	return
	if magnet_target != null:
		var direction: Vector2 = global_position.direction_to(magnet_target.global_position)
		global_translate(direction * delta * speed)
