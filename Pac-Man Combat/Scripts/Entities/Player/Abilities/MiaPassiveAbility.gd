extends Node2D

@export var ammo_bar: HBoxContainer
@export var player_gun: PlayerGun

var timer = Timer.new()

var current_chain: int = 0

var normal_icon = preload("res://Sprites/UI/SmallAmmoIcon.png")
var charged_icon = preload("res://Sprites/UI/ChargedAmmoIcon.png")

var triple_kill_sound = preload("res://Audio/SoundEffects/Player/Mia/TripleKillSound.wav")
var quad_kill_sound = preload("res://Audio/SoundEffects/Player/Mia/QuadKillSound.wav")
var ace_sound = preload("res://Audio/SoundEffects/Player/Mia/AceKillSound.wav")

var current_charges: int

var max_charges: int = 2

var last_enemy_pos: Vector2

func _ready() -> void:
	GameEvents.enemy_killed.connect(_on_enemy_killed)
	GameEvents.secondary_weapon_shot.connect(_on_secondary_shot)
	GameEvents.arena_cleared.connect(_on_arena_cleared)
	GameEvents.arena_entered.connect(_on_arena_entered)
	
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true
	timer.autostart = false
	timer.wait_time = 0.1
	add_child(timer)

func charge_next_secondary_shots(amount: int = 1):
	current_charges += amount
	if current_charges > max_charges:
		current_charges = max_charges

func _process(delta: float) -> void:

	update_special_ammos()

func update_special_ammos():
	var reserve_ammos = []
	var bullets_to_convert = current_charges
	for i in range(ammo_bar.get_child_count() - 1, -1, -1):
		var bar = ammo_bar.get_child(i)
		if bullets_to_convert > 0:
			if bar != null && bar.progress.value == 100:
				bar.progress.texture_under = charged_icon
				bar.progress.texture_progress = charged_icon
				bullets_to_convert -= 1
			elif bar != null && bar.progress.value < 100:
				reserve_ammos.append(bar)
		else:
			if bar != null && bar.progress.value == 100:
				bar.progress.texture_under = normal_icon
				bar.progress.texture_progress = normal_icon

	for bar in reserve_ammos:
		if bullets_to_convert > 0:
			bar.progress.texture_under = charged_icon
			bar.progress.texture_progress = charged_icon
			bullets_to_convert -= 1
		else:
			bar.progress.texture_under = normal_icon
			bar.progress.texture_progress = normal_icon

func _on_enemy_killed(enemy: Enemy):
	if enemy.is_in_group("Chasers"):
		timer.start()
		current_chain += 1
		
		last_enemy_pos = enemy.global_position

func set_triple_kill_title(enemy_pos: Vector2):
	var sides = [-1, 1]
	var offset = sides[randi_range(0, 1)]
	var splash_text = Global.spawn_object(ScenesPool.splash_text, enemy_pos + Vector2(offset * 16, randf_range(0, -16)), deg_to_rad(randf_range(-20, 20)))
	splash_text.initialize("TRIPLE KILL", 0.2, 0.5, 0.1, SplashText.MODE.DEFAULT, "orange")
	splash_text.scale = Vector2(1.2, 1.2)
	
	var audio_data = AudioData.new(triple_kill_sound, global_position)
	audio_data.attenuation = 0.0
	AudioManager.play_sound(audio_data)

func set_quadruple_kill_title(enemy_pos: Vector2):
	var sides = [-1, 1]
	var offset = sides[randi_range(0, 1)]
	var splash_text = Global.spawn_object(ScenesPool.splash_text, enemy_pos + Vector2(offset * 16, randf_range(0, -16)), deg_to_rad(randf_range(-30, 30)))
	splash_text.initialize("QUADRUPLE KILL", 0.2, 0.5, 0.1, SplashText.MODE.DEFAULT, "orange")
	splash_text.scale = Vector2(1.5, 1.5)
	
	var audio_data = AudioData.new(quad_kill_sound, global_position)
	audio_data.attenuation = 0.0
	AudioManager.play_sound(audio_data)

func set_ace_title(enemy_pos: Vector2):
	var sides = [-1, 1]
	var offset = sides[randi_range(0, 1)]
	var splash_text = Global.spawn_object(ScenesPool.splash_text, enemy_pos + Vector2(offset * 16, randf_range(0, -16)), deg_to_rad(randf_range(-45, 45)))
	splash_text.initialize("ACE", 0.2, 0.8, 0.1, SplashText.MODE.DEFAULT, "yellow")
	splash_text.scale = Vector2(2.0, 2.0)
	
	var audio_data = AudioData.new(ace_sound, global_position)
	audio_data.attenuation = 0.0
	AudioManager.play_sound(audio_data)


func _on_timer_timeout():
	if current_chain == 3:
		charge_next_secondary_shots(1)
			
		set_triple_kill_title(last_enemy_pos)
	elif current_chain == 4:
		charge_next_secondary_shots(2)
			
		set_quadruple_kill_title(last_enemy_pos)
	elif current_chain >= 5:
		player_gun.refill_ammos()
		charge_next_secondary_shots(2)
			
		set_ace_title(last_enemy_pos)
	
	current_chain = 0

func _on_secondary_shot():
	if current_charges > 0:
		player_gun.secondary_gun.ultracharge_next_shot = true
		current_charges -= 1

func _on_arena_cleared(arena: Arena):
	current_charges = 0
	player_gun.secondary_gun.ultracharge_next_shot = false

func _on_arena_entered(arena: Arena):
	current_charges = 0
	player_gun.secondary_gun.ultracharge_next_shot = false
