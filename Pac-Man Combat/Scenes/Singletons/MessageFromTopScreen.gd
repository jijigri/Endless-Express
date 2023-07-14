class_name MessageFromTopScreen
extends Control

@onready var text_edit: TextEdit = $TVScreen/Panel2/VBoxContainer/TextEdit

var score: int
var highscore: int

func _ready() -> void:
	visible = false
	position.y = -360

func appear(score: int):
	visible = true
	position.y = 0
	self.score = score
	self.highscore = highscore


func _on_submit_button_pressed() -> void:
	visible = false
	position.y = -360
	ScoreManager.custom_message = text_edit.text
	HUD.game_over_screen.appear(score)
