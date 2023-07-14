extends Control

@onready var parent: VBoxContainer = $List/ScrollContainer/VBoxContainer

var limit: int = 100

var display_case: PackedScene = preload("res://Scenes/UI/leaderboard_display_case.tscn")

func _ready() -> void:
	fill_scoreboard()

func fill_scoreboard():
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores(limit, "main")\
		.sw_get_scores_complete
	var scores = sw_result.scores
	var limit_index: int = 1
	
	print_debug("Found ", sw_result.scores.size(), " scores with a limit of ", limit)
	
	for score in scores:
		var instance = Global.spawn_object(display_case, Vector2(), 0, parent)
		instance.set_display_case(limit_index, score.player_name, str(int(score.score)))

		limit_index += 1
		if limit_index > limit:
			return
