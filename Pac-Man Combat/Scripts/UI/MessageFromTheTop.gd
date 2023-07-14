extends Control

@onready var text_label = $VBoxContainer/Panel/RichTextLabel
@onready var display_name_label = $VBoxContainer/DisplayNameLabel

func _ready() -> void:
	set_message()

func set_message():
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores(1).sw_get_scores_complete
	var limit_index: int = 1
	if sw_result.scores.size() > 0:
		var score = sw_result.scores[0]
		text_label.text = str(score.metadata.message)
		display_name_label.text = "-" + score.player_name
