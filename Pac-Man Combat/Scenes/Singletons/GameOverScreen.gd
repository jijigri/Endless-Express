class_name GameOverScreen
extends Control

@onready var score_label = $TVScreen/Panel2/VBoxContainer/ScoreLabel
@onready var highscore_label = $TVScreen/Panel2/VBoxContainer/HighscoreLabel
@onready var souls_label = $TVScreen/Panel2/VBoxContainer/SoulsLabel

func _ready() -> void:
	visible = false
	position.y = -360

func appear(score: int, souls_gained_this_run: int):
	print_debug("SENDING SCORE")
	var highscore: int = ScoreManager.retrieve_highscore()
	score_label.text = "SCORE: " + str(score)
	highscore_label.text = "HIGHSCORE: " + str(highscore)
	
	var souls = Global.load_player_data().souls
	souls_label.text = "SOULS: " + str(Global.load_player_data().souls) + "(+" + str(souls_gained_this_run) + ")"
	
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(), 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_ELASTIC)
	tween.play()


func _on_try_again_button_pressed() -> void:
	Global.load_scene("game")
	visible = false
	position.y = -360


func _on_main_menu_button_pressed() -> void:
	Global.load_scene("main_menu")
	visible = false
	position.y = -360
