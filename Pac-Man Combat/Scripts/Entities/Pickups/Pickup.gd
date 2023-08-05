class_name Pickup
extends Area2D

enum TYPE {HEALTH, ENERGY}

@export var type: TYPE = TYPE.HEALTH
@export var value: float = 10
@export var sound: AudioStream

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var spawner

var magnet_target = null

var magnet_speed: float = 0.0

func initialize(pickup_spawner: PickupSpawner):
	spawner = pickup_spawner

func _ready() -> void:
	GameEvents.arena_cleared.connect(_on_arena_clear)
	body_entered.connect(_body_entered)

func _process(delta: float) -> void:
	if magnet_target != null:
		global_position = global_position.move_toward(magnet_target.global_position, delta * 90 * magnet_speed)
		magnet_speed += delta * 780

func _body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") && body is CharacterBody2D:
		pickup_obtained(body)
		destroy_pickup()

func pickup_obtained(player: CharacterBody2D) -> void:
	match type:
		TYPE.HEALTH:
			player.gain_health(value)
		TYPE.ENERGY:
			player.gain_energy(value)
	
	if spawner != null:
		spawner.remove_pickup()

func _on_arena_clear(arena: Arena):
	Global.spawn_object(preload("res://Scenes/Effects/pickup_obtained_effect.tscn"), global_position)
	queue_free()

func destroy_pickup() -> void:
	var audio_data := AudioData.new(sound, global_position)
	audio_data.pitch = randf_range(0.8, 1.2)
	AudioManager.play_sound(audio_data)
	
	Global.spawn_object(preload("res://Scenes/Effects/pickup_obtained_effect.tscn"), global_position)
	
	queue_free()

func magnet_to_player(target: Node2D):
	if magnet_target != null:
		return
		
	magnet_target = target
	
