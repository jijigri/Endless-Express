extends RigidBody2D

@export var value: int = 1
@export var magnet_speed: float = 1800.0
@export var ghost_trail: GhostTrail

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@onready var magnet_target: Node2D = get_tree().get_first_node_in_group("Player")

@onready var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager")

var magnet: bool = false

var audio: AudioStream = preload("res://Audio/SoundEffects/Pickups/SoulObtainedSound.wav")

var current_lifetime: float = 0
var active: bool = true

func _ready() -> void:
	GameEvents.arena_cleared.connect(_on_arena_clear)
	GameEvents.arena_exited.connect(_on_arena_clear)
	
	collision_layer = 256
	
	
	rotation_degrees = randf_range(0, 360)
	apply_impulse(transform.y * (300 * randf_range(0.15, 2.0)))
	apply_torque(randf_range(1000, 1600))
	
	var tween = create_tween()
	tween.tween_method(set_flash_value, 1.0, 0.0, 0.5)
	tween.play()
	
	await get_tree().create_timer(0.5).timeout
	
	magnet_to_player(null)

func set_flash_value(value):
	material.set_shader_parameter("flash_modifier", value)

func _process(delta: float) -> void:
	current_lifetime += delta

func _physics_process(delta: float) -> void:
	if active == false:
		return
	if magnet != false && current_lifetime >= 0.5:
		var direction: Vector2 = global_position.direction_to(magnet_target.global_position).normalized()
		apply_force(direction * delta * magnet_speed * 100 * clamp(linear_damp * 0.65, 1.0, 1000.0))
		
		magnet_speed += delta * 12000
		
		if global_position.distance_to(magnet_target.global_position) < 16:
			active = false
			
			pickup_obtained(magnet_target)
			var tween = create_tween()
			ghost_trail.enabled = false
			#tween.tween_property(self, "scale", Vector2.ONE * 1.2, 0.1)
			tween.tween_property(self, "scale", Vector2.ZERO, 0.15).set_ease(Tween.EASE_IN)
			tween.tween_callback(destroy_pickup)
			tween.play()
			#destroy_pickup()
	

func pickup_obtained(player: CharacterBody2D) -> void:
	
	if game_manager != null:
		game_manager.gain_soul(value)
	
	AudioManager.play_in_player(
		AudioData.new(audio,
		global_position), "soul", 1, true
	)

func _on_arena_clear(arena: Arena):
	magnet_to_player(null)
	#destroy_pickup()

func destroy_pickup() -> void:
	queue_free()
	
func magnet_to_player(target: Node2D):
	if magnet == false:
		linear_damp = 20.0
		collision_mask = 0
		magnet = true
