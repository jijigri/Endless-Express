extends Control

@onready var parent: VBoxContainer = $List/ScrollContainer/VBoxContainer

var limit: int = 100

var display_case: PackedScene = preload("res://Scenes/UI/leaderboard_display_case.tscn")

func _ready() -> void:
	fill_scoreboard()

func fill_scoreboard():
	if LootLocker.authentificated == false:
		await LootLocker.authentification_complete
	
	var result = await LootLocker.get_leaderboard("main", 10).get_leaderboard_complete
	var limit_index: int = 1
	
	print_debug("Found ", result.items.size(), " scores with a limit of ", limit)
	
	for score in result.items:
		var instance = Global.spawn_object(display_case, Vector2(), 0, parent)
		instance.set_display_case(limit_index, score.player.name, str(int(score.score)))

		limit_index += 1
		if limit_index > limit:
			return
