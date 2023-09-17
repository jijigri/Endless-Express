class_name EntityMovement
extends Node2D

@export var move_speed: float = 120.0

@export var speed_over_time: Curve
@export var max_time: float = 60.0

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")
@onready var current_speed: float = move_speed

var speed_modifiers: Array[float] = []
var speed_modifier = 1.0

var time_since_last_speed_reset: float = 0.0

var rigidbody: RigidBody2D

var automatically_update: bool = true

func initialize(owner: RigidBody2D):
	rigidbody = owner

func stop():
	pass

func start():
	pass

func _process(delta: float) -> void:
	if automatically_update:
		if speed_modifiers.size() > 0:
			speed_modifier = 1.0
			for i in speed_modifiers:
				speed_modifier *= i
		else:
			speed_modifier = 1.0
		update(delta)
	
	if speed_over_time != null:
		time_since_last_speed_reset += delta
		time_since_last_speed_reset = clamp(time_since_last_speed_reset, 0.0, max_time)
		var over_time_modifier = speed_over_time.sample(time_since_last_speed_reset / max_time)
		speed_modifier *= over_time_modifier

func update(delta: float) -> void:
	pass

func stun(time: float):
	speed_modifiers.append(0.0)
	await get_tree().create_timer(time).timeout
	speed_modifiers.erase(0.0)

func is_player_visible(distance: float) -> bool:
	return not raycast_in_direction(
				global_position, 
				global_position.direction_to(player.global_position).normalized() * distance
				)

func raycast_in_direction(start_pos: Vector2, direction: Vector2) -> bool:
	var query = PhysicsRayQueryParameters2D.create(
		start_pos, start_pos + direction, 4, [self, player]
		)
	var result = get_world_2d().direct_space_state.intersect_ray(query)
	
	if result.size() > 0:
		return true
	else:
		return false

func reset_speed_over_time() -> void:
	time_since_last_speed_reset = 0.0
