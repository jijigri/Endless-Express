class_name Barrel
extends RigidBody2D

@export var roll_speed: float = 500.0
@export var speed_gain_over_time: float = 0.5

@onready var raycast: RayCast2D = $RayCast2D
@onready var ground_detection: Area2D = $GroundDetection
@onready var health_manager: HealthManager = $HealthManager
@onready var sprite = $Sprite2D
@onready var rolling_sound: AudioStreamPlayer2D = $RollingSound
@onready var destroy_sound = preload("res://Audio/SoundEffects/Misc/BarrelDestroySound.wav")

var is_grounded = false

var velocity: Vector2
var direction: int

var active: bool = true

func _ready() -> void:
	health_manager.invincible = false

func _physics_process(delta: float) -> void:
	if active == false:
		return
	
	raycast.target_position = Vector2(direction * 20.0, 0.0)
	
	if is_grounded:
		
		sprite.rotation += delta * linear_velocity.x * 0.05
		
		#linear_velocity.x = velocity.x * direction
		#velocity.x += delta * speed_gain_over_time * sign(velocity.x)
		apply_force(Vector2(direction, 0) * speed_gain_over_time * delta * 100)
		
		if abs(linear_velocity.x) < 10:
			destroy_barrel()
		
		if ground_detection.has_overlapping_bodies():
			linear_velocity.y = 0
		
		if raycast.is_colliding():
			destroy_barrel()
	else:
		if linear_velocity.y > 0:
			ground_detection.position.y = 8
		else:
			ground_detection.position.y = 0

func destroy_barrel():
	active = false
	Global.spawn_object(preload("res://Scenes/Effects/barrel_destroy_effect.tscn"), global_position)
	
	var audio_data = AudioData.new(destroy_sound, global_position)
	audio_data.max_distance = 1000
	AudioManager.play_sound(audio_data)
	
	queue_free()

func _on_ground_detection_body_entered(body: Node2D) -> void:
	if !is_grounded:
		start_rolling()

func start_rolling():
	is_grounded = true
	
	#apply_central_impulse(Vector2(velocity.x * direction, 0))
	linear_velocity = Vector2(roll_speed * direction, 0)
	
	health_manager.invincible = true
	
	rolling_sound.play()


func _on_collision_damage_damage_dealt() -> void:
	destroy_barrel()


func _on_health_manager_entity_killed() -> void:
	var instance = Global.spawn_object(preload("res://Scenes/Entities/Misc/explosion.tscn"), global_position)
	instance.initialize(34.0, 50.0, 5.0)
	destroy_barrel()
