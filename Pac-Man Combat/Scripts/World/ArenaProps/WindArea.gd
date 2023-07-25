@tool
extends Area2D

@export var force: float = 1800
@export_range(16, 1080, 16) var width: float = 64

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var source: RayCast2D = $Source

@onready var initial_target_position = source.target_position

func _ready() -> void:
	collision_shape.shape = collision_shape.shape.duplicate()
	particles.process_material = particles.process_material.duplicate()

func _process(delta: float) -> void:
		
	if Engine.is_editor_hint() == false:
		if source.is_colliding():
			var length = source.global_position.distance_to(source.get_collision_point())
			source.target_position = initial_target_position.normalized() * length
		else:
			source.target_position = initial_target_position
	
	set_editor_size()

func set_editor_size():
	if collision_shape == null:
		collision_shape = $CollisionShape2D
	if particles == null:
		particles = $GPUParticles2D
	if source == null:
		source = $Source
	
	var size = Vector2(source.target_position.x / 2, width)
	
	particles.process_material.emission_box_extents = Vector3(
		size.x - 16,
		size.y - 4,
		0
	)
	
	collision_shape.shape.size = size * 2
	collision_shape.position = source.position + (source.target_position / 2)
	
	particles.position = collision_shape.position
	var perimeter = (collision_shape.shape.size.x * 2) + (collision_shape.shape.size.y * 2)
	particles.amount = perimeter * 0.12

func _physics_process(delta: float) -> void:
	queue_redraw()
	if Engine.is_editor_hint():
		return
	
	var bodies = get_overlapping_bodies()
	if bodies.size() < 1:
		return
	for body in bodies:
		if body.is_in_group("Player"):
			var dist = source.global_position.distance_to(body.global_position)
			var curr_force = force
			body.velocity += transform.x * curr_force * delta
		elif body is Seed:
			body.apply_force(transform.x * force * delta)

func _draw() -> void:
	return
	var rect: Rect2 = Rect2(
		collision_shape.position.x - collision_shape.shape.size.x / 2,
		collision_shape.position.y - collision_shape.shape.size.y / 2,
		collision_shape.shape.size.x,
		collision_shape.shape.size.y
		)
	draw_rect(rect, Color.WHITE, false, 2.0)
