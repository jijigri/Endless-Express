extends RigidBody2D

enum TYPE {HEALTH, ENERGY}

@export var type: TYPE = TYPE.HEALTH
@export var value: float = 10
@export var magnet_speed: float = 1800.0
@export var audio: AudioStream = preload("res://Audio/SoundEffects/Packs/HealthPack.wav")

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var magnet_target: Node2D = null

var effect

func _ready() -> void:
	GameEvents.arena_cleared.connect(_on_arena_clear)
	
	effect = preload("res://Scenes/Effects/energy_pack_obtained_effect.tscn")
	
	collision_layer = 256
	
	rotation_degrees = randf_range(0, 360)
	apply_impulse(transform.y * (100 * randf_range(0.5, 1.4)))
	apply_torque(randf_range(1000, 1600))
	
	await get_tree().create_timer(8.0).timeout
	
	queue_free()

func _physics_process(delta: float) -> void:
	if magnet_target != null:
		var direction: Vector2 = global_position.direction_to(magnet_target.global_position).normalized()
		apply_force(direction * delta * magnet_speed * 100)
		
		magnet_speed += delta * 8000
		
		if global_position.distance_to(magnet_target.global_position) < 16:
			pickup_obtained(magnet_target)
			destroy_pickup()
	

func pickup_obtained(player: CharacterBody2D) -> void:
	match type:
		TYPE.HEALTH:
			player.gain_health(value)
		TYPE.ENERGY:
			player.gain_energy(value)
	
	AudioManager.play_in_player(
		AudioData.new(audio,
		global_position), "pack", 1, true
	)
	
	if effect != null:
		Global.spawn_object(effect, global_position)

func _on_arena_clear(arena: Arena):
	destroy_pickup()

func destroy_pickup() -> void:
	queue_free()
	
func magnet_to_player(target: Node2D):

	if magnet_target != null:
		return
	
	collision_mask = 0
	magnet_target = target
