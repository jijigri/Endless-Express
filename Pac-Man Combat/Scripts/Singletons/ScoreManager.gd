extends Node

var display_name: String = "player" : set = set_display_name
var highscore: int = 0

var old_position: int = 0

var custom_message: String = "I made it to the top!"

func set_display_name(value: String):
	display_name = value

func _ready() -> void:
	display_name = "Player" + OS.get_unique_id()
	set_highscore()

func set_highscore():
	var sw_result = await SilentWolf.Scores.get_top_score_by_player(display_name, 5000).sw_top_player_score_complete
	if !sw_result.top_score.is_empty():
		highscore = sw_result.top_score.s
		print_debug("Player highscore: " + str(sw_result.top_score.s))
	else:
		highscore = 0
		print_debug("Should be getting score from save file or set it to 0!")

func submit_score(score: int) -> int:
	print_debug("Hihgscore: ", highscore)
	if score > highscore:
		var metadata = {
			"message": custom_message
		}
		highscore = score
		var sw_result: Dictionary = await SilentWolf.Scores.save_score(display_name, score, "main", metadata).sw_save_score_complete
		print_debug("New highscore saved!")
		var pos_result = await SilentWolf.Scores.get_score_position(sw_result.score_id).sw_get_position_complete
		var position = pos_result.position
		print_debug("Position in leaderboard: ", position)
		return position
	return old_position

func is_top_of_leaderboard(score: int) -> bool:
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores(1).sw_get_scores_complete
	var hscore = 0
	if sw_result.scores.size() > 0:
		hscore = sw_result.scores[0].score
	if score > hscore:
		return true
	else:
		return false

func retrieve_highscore():
	return highscore
