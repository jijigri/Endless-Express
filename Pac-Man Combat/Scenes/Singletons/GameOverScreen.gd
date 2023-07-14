class_name GameOverScreen
extends Control

@onready var score_label = $TVScreen/Panel2/VBoxContainer/ScoreLabel
@onready var highscore_label = $TVScreen/Panel2/VBoxContainer/HighscoreLabel

func _ready() -> void:
	visible = false
	position.y = -360

func appear(score: int):
	ScoreManager.submit_score(score)
	print_debug("SENDING SCORE")
	var highscore: int = ScoreManager.retrieve_highscore()
	score_label.text = "SCORE: " + str(score)
	highscore_label.text = "HIGHSCORE: " + str(highscore)
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(), 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_ELASTIC)
	tween.play()


func _on_try_again_button_pressed() -> void:
	get_tree().reload_current_scene()
	visible = false
	position.y = -360


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	visible = false
	position.y = -360
