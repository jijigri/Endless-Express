class_name GameManager
extends Node2D

@export var current_score: int = 0

var old_score: int = 0

@onready var player = get_tree().get_first_node_in_group("Player")

var soul_scene = preload("res://Scenes/Entities/Pickups/soul_pickup.tscn")

var game_over: bool = false

var current_soul_amount: int = 0

func _ready() -> void:
	HUD.visible = true
	PlayerDataQueue.reset()
	PlayerDataQueue.record_player_data()
	GameEvents.score_updated.emit(current_score)
	ScoreManager.set_highscore()
	HUD.player_hud.update_soul_count(current_soul_amount)
	
	await get_tree().process_frame
	player.health_manager.entity_killed.connect(on_player_entity_killed)

func _process(delta: float) -> void:

	if Input.is_action_just_pressed("toggle_debug_mode"):
		Global.debug_mode = !Global.debug_mode

func increase_score(amount: int):
	old_score = current_score
	current_score += amount
	GameEvents.score_updated.emit(current_score)

	for i in amount * 10:
		Global.spawn_object(soul_scene, player.global_position)

func gain_soul(amount: int = 1):
	current_soul_amount += amount
	HUD.player_hud.update_soul_count(current_soul_amount)

func game_end():
	PlayerDataQueue.stop_recording()
	CameraManager.freeze(0.2)
	CameraManager.shake(10, 0.5)
	
	submit_data()
	
	var is_top: bool = await ScoreManager.is_top_of_leaderboard(current_score)
	if is_top:
		HUD.message_from_top_screen.appear(self)
	else:
		HUD.game_over_screen.appear(current_score, current_soul_amount)

	game_over = true

func submit_data():
	ScoreManager.submit_score(current_score)
	
	var save_data = Global.load_player_data()
	save_data.souls += current_soul_amount
	
	Global.save_player_data(save_data)

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
