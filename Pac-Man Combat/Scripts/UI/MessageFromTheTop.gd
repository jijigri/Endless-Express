extends Control

@onready var text_label = $VBoxContainer/Panel/RichTextLabel
@onready var display_name_label = $VBoxContainer/DisplayNameLabel

func _ready() -> void:
	if LootLocker.authentificated == false:
		await LootLocker.authentification_complete
	set_message()

func set_message():
	var result: Dictionary = await LootLocker.get_leaderboard("main", 50).get_leaderboard_complete
	var limit_index: int = 1
	if result.items.size() > 0:
		var score = result.items[0]
		text_label.text = str(score.metadata)
		display_name_label.text = "-" + score.player.name
