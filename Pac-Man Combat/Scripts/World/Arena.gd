class_name Arena
extends Node2D

@export var entrance_door: Door
@export var exit_door: Door

@onready var chaser_spawner: ChaserSpawner = $ChaserSpawner
@onready var target_spawner: TargetSpawner = $TargetSpawner
@onready var pickup_spawner: PickupSpawner = $PickupSpawner

@onready var player: Player = get_tree().get_first_node_in_group("Player")

@onready var level_map: TileMap = $Map/Level
@onready var navigation_map: TileMap = $Map/NavigationMap

@onready var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager")

var is_flawless = true

func _ready() -> void:
	
	navigation_map.visible = false
	
	var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")
	player.global_position = entrance_door.global_position + (Vector2.RIGHT * 32)
	
	player.gain_health(1000)
	player.gain_energy(-1000)
	player.player_gun.refill_ammos()
	
	GameEvents.player_damaged.connect(_on_player_damaged)
	
	entrance_door.initialize(self)
	exit_door.initialize(self)
	
	entrance_door.close()
	exit_door.close()
	#on_arena_clear()
	
	GameEvents.arena_entered.emit(self)
	
	await get_tree().create_timer(1.0).timeout
	
	var countdown_data = AudioData.new(preload("res://Audio/SoundEffects/Misc/CountdownSound.wav"), global_position)
	var start_data = AudioData.new(preload("res://Audio/SoundEffects/Misc/ArenaStartSound.wav"), global_position)
	#HUD.play_countdown()
	HUD.play_sliding_text("3", 0.6, 0.1, countdown_data)
	await get_tree().create_timer(0.8).timeout
	HUD.play_sliding_text("2", 0.6, 0.1, countdown_data)
	await get_tree().create_timer(0.8).timeout
	HUD.play_sliding_text("1", 0.6, 0.1, countdown_data)
	await get_tree().create_timer(0.8).timeout
	HUD.play_sliding_text("GO", 0.6, 0.1, start_data)
	await get_tree().create_timer(0.3).timeout
	var whistle = AudioData.new(preload("res://Audio/SoundEffects/Misc/WhistleBlow.mp3"), global_position)
	AudioManager.play_sound(whistle)
	MusicHandler.start_gameplay_music()
	
	start_arena()

func start_arena():
	chaser_spawner.spawn_enemies(self)
	target_spawner.spawn_enemies(self)
	pickup_spawner.spawn_pickups(self)
	
	is_flawless = true

func on_arena_clear() -> void:

	print_debug("ARENA CLEAR " + exit_door.name)
	var score_gain = 1
	if is_flawless:
		score_gain += 1
	game_manager.increase_score(score_gain)
	
	GameEvents.arena_cleared.emit(self)
	
	player.gain_health(1000)
	player.gain_energy(-1000)
	player.player_gun.refill_ammos()
	
	var audio_data = AudioData.new(preload("res://Audio/SoundEffects/Misc/ArenaClearSound.wav"), global_position)
	AudioManager.play_sound(audio_data)
	HUD.play_smash_title("CAR COMPLETE", 0.8, 0.2, 0.25)
	
	MusicHandler.stop_music()
	
	display_stat_titles()
	
	exit_door.open()

func display_stat_titles():
	if is_flawless:
		await get_tree().create_timer(1.0).timeout
		HUD.play_sliding_text("FLAWLESS\n+1", 0.8, 0.25)

func _on_player_damaged(current_health: float, max_health: float, value: float):
	is_flawless = false
