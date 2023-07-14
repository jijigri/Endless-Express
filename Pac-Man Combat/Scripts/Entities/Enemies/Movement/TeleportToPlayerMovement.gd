extends EntityMovement

@export var teleport_duration: float = 0.5

@onready var arena_manager = get_tree().get_first_node_in_group("ArenaManager")
@onready var player_prediction: PlayerPrediction = $PlayerPrediction

var last_player_velocity: Vector2 = Vector2()

signal teleport_began
signal teleport_ended

func _process(delta: float) -> void:
	super._process(delta)
	player_prediction.get_prediction_position()

func teleport(to_player: bool = true) -> void:
	if speed_modifier == 0:
		return
	
	teleport_began.emit()
	
	if speed_modifier == 0:
		return
	
	var target_position
	
	if to_player:
		target_position = player_prediction.get_prediction_position()
	else:
		target_position = arena_manager.get_random_position_on_navmesh()
	
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
	
	teleport_ended.emit()
