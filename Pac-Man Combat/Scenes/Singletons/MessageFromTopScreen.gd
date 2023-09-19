class_name MessageFromTopScreen
extends Control

@onready var text_edit: TextEdit = $TVScreen/Panel2/VBoxContainer/TextEdit

var score: int
var highscore: int
var souls: int

func _ready() -> void:
	visible = false
	position.y = -360

func appear(game_manager: GameManager):
	visible = true
	position.y = 0
	self.score = game_manager.current_score
	self.highscore = highscore
	self.souls = game_manager.current_soul_amount


func _on_submit_button_pressed() -> void:
	visible = false
	position.y = -360
	ScoreManager.custom_message = text_edit.text
	var game_manager = get_tree().get_first_node_in_group("GameManager")
	
	HUD.game_over_screen.appear(score, souls)
