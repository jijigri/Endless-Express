class_name GameManager
extends Node2D

@export var current_score: int = 0

@onready var player = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	HUD.visible = true
	PlayerDataQueue.reset()
	PlayerDataQueue.record_player_data()
	GameEvents.score_updated.emit(current_score)
	ScoreManager.set_highscore()
	
	await get_tree().process_frame
	player.health_manager.entity_killed.connect(on_player_entity_killed)

func increase_score(amount: int):
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

func on_player_entity_killed():
	game_end()
