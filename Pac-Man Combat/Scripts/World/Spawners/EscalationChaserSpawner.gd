extends Node2D

@onready var chaser_spawner: ChaserSpawner = get_parent()

var current_wave_index: int = 0
var amount_of_waves: int = 0

var start_sound = preload("res://Audio/SoundEffects/Misc/EscalationBattleStartSound.wav")

var enemies_to_spawn_per_wave = {
	
}

var current_number_of_enemies_in_world: int = 0
var last_amount_of_enemies_spawned: int = 0

var sample_intensity: float = 0.0

func _ready() -> void:
	chaser_spawner.chaser_removed.connect(on_chaser_removed)

func start_escalation_spawn():
	self.amount_of_waves = get_amount_of_waves()
	
	var string = "ESCALATION BATTLE - " + str(amount_of_waves) + " WAVES"
	HUD.play_sliding_text(string, 0.8, 0.8)
	
	AudioManager.play_global(AudioData.new(start_sound))
	
	chaser_spawner.reset_spawn_weights()

	current_wave_index = 0
	chaser_spawner.current_number_of_enemies = set_enemies_to_spawn_per_wave(amount_of_waves)
	
	escalation_waves()

func get_amount_of_waves() -> int:
	var current_score = chaser_spawner.game_manager.current_score
	var additional_waves: int = floori(current_score / 20)
	return 3 + additional_waves

func set_enemies_to_spawn_per_wave(amount_of_waves):
	var amount_of_enemies: int = 0
	
	var score: float = 0.0
	var step: float = chaser_spawner.game_manager.current_score / amount_of_waves
	for i in amount_of_waves:
		score += step
		var damper: float = amount_of_waves - i
		#damper = (1.0 / damper) * 0.8
		var intensity: float = get_intensity(score, 0.75 - (damper / (amount_of_waves * 10)))
		print_debug("INTENSITY: ", intensity)
		sample_intensity = intensity
		var enemies_to_spawn: Array[ChaserEnemyData] = chaser_spawner.get_enemies_to_spawn(intensity, score)
		enemies_to_spawn_per_wave[i] = enemies_to_spawn
		amount_of_enemies += enemies_to_spawn.size()
	
	return amount_of_enemies

func escalation_waves():
	while current_wave_index < amount_of_waves:
		if chaser_spawner.game_manager.game_over:
			return
		
		spawn_wave(current_wave_index)
		current_wave_index += 1
		var wait_time = clamp(sample_intensity * 0.5, 4.0, 10.0)
		#print_debug("Wait time: ", wait_time)
		#make timer into a real timer so it can reset when respawning
		await get_tree().create_timer(wait_time).timeout

func spawn_wave(index: int = 0):
	if chaser_spawner.enabled == false:
		return

	var enemies_to_spawn = enemies_to_spawn_per_wave[index]
	
	for i in enemies_to_spawn:
		var pos: Vector2 = chaser_spawner.arena_manager.get_random_position_on_navmesh()
		Global.spawn_chaser(SpawnIndicatorType.TYPE.DANGER, i.scene, pos, 0, chaser_spawner.get_parent(), i.level)
	
	last_amount_of_enemies_spawned = enemies_to_spawn.size()
	current_number_of_enemies_in_world += last_amount_of_enemies_spawned
	
	chaser_spawner.set_retreat_times(sample_intensity)

func get_intensity(score: int, damper: float = 1.0) -> float:
	
	if score < 0:
		return -1
	
	var intensity_min = chaser_spawner.intensity_curve_min.sample(
		(score % chaser_spawner.curve_sample_size) / float(chaser_spawner.curve_sample_size)
		)
	var intensity_max = chaser_spawner.intensity_curve_max.sample(
		(score % chaser_spawner.curve_sample_size) / float(chaser_spawner.curve_sample_size)
		)
	
	var add_score = floori(score / chaser_spawner.curve_sample_size) * chaser_spawner.curve_sample_size
	
	var rand_intensity = randf_range(intensity_min, intensity_max)
	return clamp(rand_intensity * damper, 1, 9999999) + 1 + add_score

func on_chaser_removed():
	current_number_of_enemies_in_world -= 1
	if current_number_of_enemies_in_world < last_amount_of_enemies_spawned / 2:
		pass
