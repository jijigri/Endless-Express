extends Area2D

@export var rigidbody: RigidBody2D
@export var push_force: float = 300
@export var ignore_y: bool = false

func _ready() -> void:
	if rigidbody == null:
		rigidbody = owner

func _process(delta: float) -> void:
	
	var colliders = get_overlapping_bodies()
	if(colliders.size() > 0):
		for col in colliders:
			if col != owner:
				var direction: Vector2 = (global_position - col.global_position).normalized()
				
				var push_direction = direction
				
				if ignore_y:
					if direction.x == 0:
						var directions = [-1, 1]
						direction.x = randi_range(0, directions.size() - 1)
					push_direction = Vector2(sign(direction.x), 0)
				
				rigidbody.apply_force(push_direction * push_force)
