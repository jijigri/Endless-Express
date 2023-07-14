extends LineEdit

func _ready() -> void:
	text = ScoreManager.display_name

func _on_text_changed(new_text: String) -> void:
	if new_text != "":
		ScoreManager.display_name = new_text
