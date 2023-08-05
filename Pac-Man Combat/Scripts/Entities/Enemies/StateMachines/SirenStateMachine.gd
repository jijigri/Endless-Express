extends TargetStateMachine

@export var damage_to_cancel_summoning: float = 50
@export var time_to_summon: float = 4.0

@onready var arena_manager = get_tree().get_first_node_in_group("ArenaManager")
@onready var enemy_spawner = arena_manager.current_arena.chaser_spawner
@onready var summon_effect = preload("res://Scenes/Effects/summon_effect.tscn")
@onready var summon_sound = $SummoningSound
@onready var current_intensity: float = initial_intensity

var damage_taken_during_summon: float = 0

var initial_intensity: float = 2.0
var intentity_gain_by_teleport: float = 2.0

var summon_effects = []

var time: float = 0.0

func _ready() -> void:
	super._ready()
	default_movement.teleport_ended.connect(_on_teleport_ended)
	summon_sound.playing = false
	appear()

func _process(delta: float) -> void:
	var pitch_modulate = sin(time * 2) * 0.25
	summon_sound.pitch_scale = 1 + pitch_modulate
	time += delta

func appear():
	damage_taken_during_summon = 0
	sprite.play("appear")

func start_spawning():
	print_debug("Spawning enemies!")
	
	sprite.play("default")
	
	if can_summon():
		await summon_enemies()
	
	disappear()

func disappear():
	sprite.play("disappear")
	var audio_data = AudioData.new(preload("res://Audio/SoundEffects/Enemies/TargetSiren/SirenTeleportStartSound.wav"), global_position)
	audio_data.max_distance = 1000
	AudioManager.play_sound(audio_data)

func _on_teleport_ended() -> void:
	current_intensity += intentity_gain_by_teleport
	appear()
	
	var audio_data = AudioData.new(preload("res://Audio/SoundEffects/Enemies/TargetSiren/SirenTeleportEndSound.wav"), global_position)
	audio_data.max_distance = 1000
	AudioManager.play_sound(audio_data)

func summon_enemies():
	if frozen || !can_summon():
		return
	
	summon_sound.playing = true
	
	if enemy_spawner == null:
		enemy_spawner = arena_manager.current_arena.chaser_spawner
	
	enemy_spawner.reset_spawn_weights()
	
	var enemies_to_spawn: Array[PackedScene] = enemy_spawner.get_enemies_to_spawn(current_intensity, current_intensity * 2)
	var positions: Array[Vector2] = []
	if summon_effects.size() > 0:
		destroy_summon_effects(true)
	for i in enemies_to_spawn:
		var pos = arena_manager.get_random_position_on_navmesh()
		positions.append(pos)
		var instance = Global.spawn_object(summon_effect, pos)
		summon_effects.append(instance)
	
	destroy_summon_effects()
	
	await get_tree().create_timer(time_to_summon).timeout
	
	if frozen || !can_summon():
		summon_sound.playing = false
		return
	
	spawn_enemies(enemies_to_spawn, positions)
	
	summon_sound.playing = false

func destroy_summon_effects(instant: bool = false):
	if !instant:
		await get_tree().create_timer(time_to_summon).timeout
	if summon_effects.size() > 0:
		for i in summon_effects:
			if i != null:
				i.queue_free()
	summon_effects.clear()

func spawn_enemies(enemies_to_spawn, positions):
	for i in enemies_to_spawn.size():
		var pos: Vector2 = positions[i]
		Global.spawn_with_indicator(SpawnIndicatorType.TYPE.DANGER, enemies_to_spawn[i], pos, 0, enemy_spawner.get_parent())
	
	enemy_spawner.current_number_of_enemies += enemies_to_spawn.size()
	
	var audio_data = AudioData.new(preload("res://Audio/SoundEffects/Enemies/TargetSiren/SirenSummoningFinishSound.wav"), global_position)
	audio_data.max_distance = 1000
	audio_data.attenuation = 0.0
	AudioManager.play_sound(audio_data)

func on_damaged(damage_data):
	super.on_damaged(damage_data)
	damage_taken_during_summon += damage_data.damage

func can_summon() -> bool:
	return damage_taken_during_summon < damage_to_cancel_summoning

func kill():
	super.kill()
	
	if summon_effects.size() > 0:
		destroy_summon_effects(true)
	summon_effects.clear()

func _on_sprite_animation_finished() -> void:
	if sprite.animation == "appear":
		start_spawning()
	elif sprite.animation == "disappear":
		current_state.teleport()

func _on_status_effects_manager_effect_removed(effect) -> void:
	if effect == "freeze":
		disappear()


func _on_status_effects_manager_effect_applied(effect, duration) -> void:
	if effect == "freeze":
		sprite.play("default")
