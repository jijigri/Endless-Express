class_name Enemy
extends Entity

@export var default_movement: EntityMovement
@export var death_effect: PackedScene
@export var death_sound: AudioStream
@export var spawn_sound: AudioStream

@onready var current_state: EntityMovement = default_movement
@onready var movement_states: Array = [default_movement]
@onready var health_manager: HealthManager = $HealthManager
@onready var status_effects_manager: StatusEffectsManager = $StatusEffectsManager

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hit_effect = preload("res://Scenes/Effects/enemy_hit_effect.tscn")

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hurtbox: Hurtbox = $Hurtbox

var updating_direction: bool = true

var frozen: bool = false
var stagger_stacks: int = 0 : set = set_stagger_stacks

var staggered: bool = false : get = is_staggered

signal killed(global_pos)

func set_stagger_stacks(value):
	stagger_stacks = clamp(value, 0, 1000)

func is_staggered() -> bool:
	return stagger_stacks > 0

func _ready() -> void:
	for state in movement_states:
		state.initialize(self)
	
	GameEvents.player_killed.connect(_on_player_killed)
	
	set_processes()
	
	if spawn_sound != null:
		var audio_data: AudioData = AudioData.new(spawn_sound, global_position)
		audio_data.max_distance = 1000
		AudioManager.play_sound(audio_data)
	
	var game_manager = get_tree().get_first_node_in_group("GameManager")
	if game_manager != null:
		if game_manager.game_over:
			kill()

func add_movement_state(state: EntityMovement):
	movement_states.append(state)

func set_processes():
	for state in movement_states:
		if state == current_state:
			state.set_process(true)
			state.set_physics_process(true)
		else:
			state.set_process(false)
			state.set_physics_process(false)

func set_state(state: EntityMovement):
	current_state.stop()
	current_state = state
	set_processes()
	current_state.start()

func _on_health_manager_health_updated(current_health, max_health, damage_data) -> void:
	if damage_data.damage > 0:
		on_damaged(damage_data)

func on_damaged(damage_data):
	if !frozen:
		apply_impulse(damage_data.velocity)
	
	Global.spawn_object(hit_effect, damage_data.hit_position, randf_range(0.0, 360.0))
	play_hit_sound()
	
	GameEvents.enemy_damaged.emit(self)

func play_hit_sound():
	pass

func _on_health_manager_entity_killed() -> void:
	CameraManager.freeze(0.12)
	kill()

func _on_player_killed() -> void:
	if death_effect != null:
		Global.spawn_object(death_effect, global_position)
	
	if death_sound != null:
		AudioManager.play_in_player(AudioData.new(death_sound, global_position), "death_sound", 1, true)
	
	queue_free()

func kill() -> void:
	GameEvents.enemy_killed.emit(self)
	killed.emit(global_position)
	
	if death_effect != null:
		Global.spawn_object(death_effect, global_position)
	
	if death_sound != null:
		AudioManager.play_in_player(AudioData.new(death_sound, global_position), "death_sound", 2, true)
	
	queue_free()
