extends LineEdit

func _ready() -> void:
	text = "player"
	if LootLocker.authentificated == false:
		await LootLocker.authentification_complete
	text = await LootLocker.get_player_name().get_name_complete

func _on_text_changed(new_text: String) -> void:
	if new_text != "":
		ScoreManager.display_name = new_text


func _on_text_submitted(new_text: String) -> void:
	if LootLocker.authentificated == false:
		await LootLocker.authentification_complete
	
	LootLocker.set_player_name(new_text)
