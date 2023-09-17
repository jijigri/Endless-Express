class_name GameManager
extends Node2D

@export var current_score: int = 0

var old_score: int = 0

@onready var player = get_tree().get_first_node_in_group("Player")

var game_over: bool = false

func _ready() -> void:
	HUD.visible = true
	PlayerDataQueue.reset()
	PlayerDataQueue.record_player_data()
	GameEvents.score_updated.emit(current_score)
	ScoreManager.set_highscore()
	
	await get_tree().process_frame
	player.health_manager.entity_killed.connect(on_player_entity_killed)

func _process(delta: float) -> void:

	if Input.is_action_just_pressed("toggle_debug_mode"):
		Global.debug_mode = !Global.debug_mode

func increase_score(amount: int):
	old_score = current_score
	current_score += amount
	GameEvents.score_updated.emit(current_score)

func game_end():
	PlayerDataQueue.stop_recording()
	CameraManager.freeze(0.2)
	CameraManager.shake(10, 0.5)
	
	var is_top: bool = await ScoreManager.is_top_of_leaderboard(current_score)
	if is_top:
		HUD.message_from_top_screen.appear(current_score)
	else:
		HUD.game_over_screen.appear(current_score)

	game_over = true

func has_passed_by_score(score: int) -> bool:
	if score == current_score:
		return true
	
	var test_score = old_score
	while test_score < current_score:
		if test_score == score:
			return true
		test_score += 1
	
	return false

func on_player_entity_killed():
	game_end()
