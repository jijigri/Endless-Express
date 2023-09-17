extends ChaserStateMachine

@export var speed_over_rounds: Curve

func _ready() -> void:
	super._ready()
	var score = get_tree().get_first_node_in_group("GameManager").current_score

	var max_score = 32.0
	var score_clamped = clamp(score, 1.0, max_score)
	#score_clamped = 32.0
	var sample_point = score_clamped / max_score
	var speed_modifier = 1.0 + speed_over_rounds.sample(sample_point)
	default_movement.speed_modifiers.append(speed_modifier)
	
	
	default_movement.min_predict_distance_in_tiles = clamp((34.0 - score_clamped) / 1.5, 8, 100)
	default_movement.max_predict_distance_in_tiles = clamp((34.0 - score_clamped) / 1.5, 8, 100) + 4
