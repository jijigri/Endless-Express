extends ChaserStateMachine

@export var distance_to_attack: float = 512
@export var angry_movement: EntityMovement
@export var close_movement: EntityMovement
@export var explosion_scene: PackedScene
@export var explosion_size: float = 64.0
@export var explosion_damage: float = 40.0

@onready var raycast: RayCast2D = $RayCast2D

@onready var normal_particles = $Sprite/NormalParticles
@onready var angry_particles = $Sprite/AngryParticles

@onready var angry_sound = $AngrySound

@onready var detect_sound = preload("res://Audio/SoundEffects/Enemies/SwappyRocket/SwappyRocketDetect.wav")

var active: bool = true

func _ready() -> void:
	add_movement_state(angry_movement)
	add_movement_state(close_movement)
	
	normal_particles.visible = true
	angry_particles.visible = false
	
	get_angry()
	
	super._ready()


func _process(delta: float) -> void:
	super._process(delta)
	
	
	if sprite.animation == "default":
		pass
		"""
		raycast.target_position = player.global_position - global_position
		print_debug("COLLIDING? ", raycast.is_colliding())
		if distance_to_player < distance_to_attack && raycast.is_colliding() == false:
			get_angry()
		"""
	elif sprite.animation == "angry":
		if distance_to_player < 64.0:
			set_state(close_movement)
		elif distance_to_player < 24.0 && !frozen:
			explode()

func get_angry():
	sprite.play("angry")
	set_state(angry_movement)
	linear_damp = 10
	#collision_shape.shape.size = Vector2(32, 20)
	hurtbox.collision_shape.shape.size = Vector2(50, 28)
	
	var audio_data = AudioData.new(detect_sound, global_position)
	audio_data.max_distance = 800
	AudioManager.play_sound(audio_data)
	
	normal_particles.visible = false
	angry_particles.visible = true
	
	angry_sound.volume_db = -20
	angry_sound.play()
	
	var sound_tween = create_tween()
	sound_tween.tween_property(angry_sound, "volume_db", 0.0, 0.8)
	sound_tween.play()
	
	var damp_tween = create_tween()
	damp_tween.tween_property(self, "linear_damp", 2.5, 18.0)
	damp_tween.play()

func _on_sprite_animation_finished() -> void:
	if sprite.animation == "detect":
		sprite.play("angry")


func set_sprite_direction():
	var angle = Helper.angle_between(global_position, global_position + linear_velocity.normalized())
	sprite.rotation_degrees = angle


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Solid"):
		kill()
	elif body.is_in_group("Player"):
		if !frozen:
			explode()

func explode() -> void:
	if active:
		var instance = Global.spawn_object(explosion_scene, global_position)
		instance.initialize(explosion_size, explosion_damage, 0.0)
		kill()
		active = false
