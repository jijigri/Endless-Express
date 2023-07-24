extends Area2D

@export var direction: Vector2 = Vector2(0, -1)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _physics_process(delta: float) -> void:
	queue_redraw()
	
	var bodies = get_overlapping_bodies()
	if bodies.size() < 1:
		return
	for body in bodies:
		if body.is_in_group("Player"):
			var dist = collision_shape.global_position.distance_to(body.global_position)
			body.velocity += direction * 1800 * delta

func _draw() -> void:
	var rect: Rect2 = Rect2(
		collision_shape.position.x - collision_shape.shape.size.x / 2,
		collision_shape.position.y - collision_shape.shape.size.y / 2,
		collision_shape.shape.size.x,
		collision_shape.shape.size.y
		)
	#draw_rect(rect, Color.AQUA, true)
