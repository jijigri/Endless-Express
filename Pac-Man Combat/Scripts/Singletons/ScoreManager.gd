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
	if LootLocker.authentificated == false:
		await LootLocker.authentification_complete
	var score = await LootLocker.get_rank("main").get_rank_complete
	
	highscore = score
	print_debug("Player highscore: " + str(score))

func submit_score(score: int) -> int:
	print_debug("Hihgscore: ", highscore)
	if score > highscore:
		var metadata = custom_message
		highscore = score
		var result = await LootLocker.upload_score(score, "main", metadata).submit_score_complete
		print_debug("New highscore saved!")
		var position = result.rank
		print_debug("Position in leaderboard: ", position)
		return position
	return old_position

func is_top_of_leaderboard(score: int) -> bool:
	var result: Dictionary = await LootLocker.get_leaderboard("main", 1).get_leaderboard_complete
	var hscore = 0
	if result.items.size() > 0:
		hscore = result.items[0].score
	if score > hscore:
		return true
	else:
		return false

func retrieve_highscore():
	return highscore
