extends ChaserStateMachine

@onready var collision_damage = $ChaserAttacksHolder/CollisionDamage
@onready var health_bar: OverheadHealthBar = $ArmoredHealthBar
@onready var flap_audio = AudioData.new(preload("res://Audio/SoundEffects/Enemies/Eagle/EagleWingFlap.wav"), global_position)

var is_rotation_locked_on_player: bool = false

func _ready() -> void:
	super._ready()
	collision_damage.area.monitoring = false
	flap_audio.max_distance = 400

func set_sprite_direction():
	if !updating_direction:
		return
	
	if !is_rotation_locked_on_player:
		super.set_sprite_direction()
		sprite.flip_v = false
		sprite.flip_h = false
		sprite.rotation_degrees = 0
	else:
		sprite.scale.x = 1
		if sprite.rotation_degrees > 90 || sprite.rotation_degrees < -90:
			sprite.flip_v = true
		else:
			sprite.flip_v = false
		sprite.flip_h = true
		sprite.rotation = get_angle_to(player.global_position)

func _on_dash_movement_dash_began() -> void:
	collision_damage.area.monitoring = true
	AudioManager.play_sound(AudioData.new(preload("res://Audio/SoundEffects/Enemies/Eagle/EagleDashSound.wav"), global_position))
	sprite.play("dash")


func _on_dash_movement_dash_ended() -> void:
	collision_damage.area.monitoring = false
	sprite.play("stun")
	health_bar.visible = false
	AudioManager.play_sound(AudioData.new(preload("res://Audio/SoundEffects/Enemies/Eagle/EagleStunSound.wav"), global_position))
	is_rotation_locked_on_player = false

func _on_health_manager_health_updated(current_health, max_health, damage_data) -> void:
	super._on_health_manager_health_updated(current_health, max_health, damage_data)
	if current_state is DashMovement:
		if current_state.state == DashMovement.State.STUNNED:
			health_manager.break_armor()
			health_bar.visible = true


func _on_dash_movement_charge_began() -> void:
	sprite.play("charge")
	is_rotation_locked_on_player = true
	AudioManager.play_sound(AudioData.new(preload("res://Audio/SoundEffects/Enemies/Eagle/EagleChargeSound.wav"), global_position))


func _on_dash_movement_pathfinding_began() -> void:
		sprite.play("default")
		health_bar.visible = true


func _on_sprite_frame_changed() -> void:
	flap_audio.position = global_position
	if sprite.animation != "dash":
		if sprite.frame == 4:
			AudioManager.play_sound(flap_audio)
