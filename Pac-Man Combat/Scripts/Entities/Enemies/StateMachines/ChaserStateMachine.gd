class_name ChaserStateMachine
extends Enemy

@export var retreat_movement: EntityMovement

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var spawner = get_tree().get_first_node_in_group("ArenaManager").current_arena.chaser_spawner

var attacks: Array[EnemyAttack]

var distance_to_player: float

func _ready() -> void:
	if retreat_movement != null:
		add_movement_state(retreat_movement)
	
	for attack in $ChaserAttacksHolder.get_children():
		attack.initialize(self)
		attacks.append(attack)
	
	if sprite != null:
		if sprite.has_method("disable"):
			sprite.disable()
	
	super._ready()

func _process(delta: float) -> void:
	
	distance_to_player = global_position.distance_to(player.global_position)
	
	set_sprite_direction()


func set_sprite_direction():
	if !updating_direction:
		return
	
	if distance_to_player > 512:
		if linear_velocity.x < 0:
			sprite.scale.x = 1
		elif linear_velocity.x > 0:
			sprite.scale.x = -1
	else:
		var dir: float = global_position.direction_to(player.global_position).x
		if abs(dir) < 0.01:
			dir = 1
		sprite.scale.x = -sign(dir)

func retreat(time: float):
	if retreat_movement == null:
		return
	
	if current_state == retreat_movement:
		return
	
	current_state.stop()
	current_state = retreat_movement
	set_processes()
	current_state.start()
	
	await get_tree().create_timer(time).timeout
	
	current_state.stop()
	current_state = default_movement
	set_processes()
	current_state.start()

func play_hit_sound():
	
	var sound_path: String = ""
	var pitch: float = 1.0
	if health_manager is ArmoredHealthManager:
		if health_manager.is_armored:
			sound_path = AudioManager.AUDIO_PATH + "Enemies/ChaserArmoredHitSound.wav"
		else:
			var array = ["Enemies/ChaserHitSound.wav", "Enemies/ChaserHitSound02.wav"]
			sound_path = AudioManager.AUDIO_PATH + array.pick_random()
			pitch = randf_range(0.75, 1.2)
	
	var audio_data = AudioData.new(load(sound_path), global_position)
	audio_data.pitch = pitch
	audio_data.volume = 1.5
	
	AudioManager.play_in_player(
				audio_data
				, "hit_sound", 3, true
			)

func kill() -> void:

	if spawner != null:
		spawner.remove_chaser()
		
	super.kill()

func _on_health_manager_armor_broken() -> void:
	var audio_data: AudioData = AudioData.new(
		preload("res://Audio/SoundEffects/Enemies/ArmorBreakSound.wav"),
		global_position
		)
	
	audio_data.volume = 3.0
	
	AudioManager.play_in_player(audio_data, "armor_break", 2)
	
	if sprite != null:
		if sprite.has_method("enable"):
			sprite.enable()


func _on_health_manager_armor_repaired() -> void:
	if sprite != null:
		if sprite.has_method("disable"):
			sprite.disable()
