extends EntityMovement

@export var teleport_duration: float = 0.5
#@export var periodically_teleport: bool = false

@onready var arena_manager = get_tree().get_first_node_in_group("ArenaManager")

var teleport_effect: GPUParticles2D

signal teleport_began
signal teleport_ended

func _ready() -> void:
	teleport_effect = $TeleportEffect
	teleport_effect.call_deferred("reparent", get_tree().root)
	teleport_effect.emitting = false

func update(delta: float) -> void:
	teleport_effect.global_position = global_position

func teleport() -> void:
	if speed_modifier == 0:
		return
	print_debug("Teleporting!")
	
	teleport_began.emit()
	
	if speed_modifier == 0:
		return
		
	var target_position = get_teleport_position()
	
	teleport_effect.emitting = true
	
	rigidbody.visible = false
	rigidbody.set_process(false)
	rigidbody.set_physics_process(false)
	
	var tween = create_tween()
	tween.tween_property(rigidbody, "global_position", target_position, teleport_duration)
	tween.tween_callback(arrive_at_destination.bind(target_position))
	tween.play()


func arrive_at_destination(target_position: Vector2) -> void:
	rigidbody.global_position = target_position
	rigidbody.visible = true
	rigidbody.set_process(true)
	rigidbody.set_physics_process(true)
	
	teleport_effect.emitting = false
	
	teleport_ended.emit()

func get_teleport_position() -> Vector2:

	var random_position: Vector2 = arena_manager.get_random_position_on_navmesh()
	return random_position

func _exit_tree() -> void:
	teleport_effect.queue_free()
