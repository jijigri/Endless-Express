extends ChaserStateMachine

@export var teleport_movement: EntityMovement
@export var chase_movement: EntityMovement
@export var detection_radius: float = 80.0
@export var time_to_trigger: float = 0.25
@export var time_to_teleport: float = 0.8
@export var cooldown: float = 2.0
@export var circle_color: Color = Color(0.0, 0.0, 0.0, 0.25)
@export var circle_outline_color: Color =  Color(0.0, 0.0, 0.0, 1.0)

@onready var chase_timer: Timer = $ChaseTimer
@onready var initial_radius = detection_radius

@onready var wing_flap_sound_1 = preload("res://Audio/SoundEffects/Enemies/Bat/BatWingFlapSound.wav")
@onready var wing_flap_sound_2 = preload("res://Audio/SoundEffects/Enemies/Bat/BatWingFlapSound02.wav")
@onready var scream_sound = preload("res://Audio/SoundEffects/Enemies/Bat/BatScreamSound.wav")
@onready var attack_sound = preload("res://Audio/SoundEffects/Enemies/Bat/BatAttackSound.wav")
@onready var disappear_sound = preload("res://Audio/SoundEffects/Enemies/Bat/BatDisappearSound.wav")
@onready var appear_sound = preload("res://Audio/SoundEffects/Enemies/Bat/BatAppearSound.wav")
@onready var melee_sound = preload("res://Audio/SoundEffects/Enemies/Bat/BatMeleeSound.wav")

@onready var cooldown_circle = $CooldownCircle

var time_passed: float = 0

var trigger_timer = 0.0

var is_on_cooldown: bool = false

#SLEEPS OR WANDERS AROUND WITH A ZONE AROUND
#WHEN PLAYER ENTERS ZONE OR WHEN SHOT, TELEPORT IN FRONT OF PLAYER
#BLASTS SHOTGUN TO PLAYER FACE
#TELEPORTS AWAY
#STARTS SLEEPING AGAIN
#WHEN ENEMY COUNT IS LOW, STARTS MOVING TOWARDS PLAYER
#MAYBE TELEPORTS AWAY WHEN TOO LOW ON HEALTH
#TRIES TO HEAL WHILE AWAY

func _ready() -> void:
	add_movement_state(teleport_movement)
	add_movement_state(chase_movement)
	
	detection_radius = 0.0
	
	var tween = create_tween()
	tween.tween_property(self, "detection_radius", initial_radius, 0.25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.play()
	
	cooldown_circle.progress.max_value = time_to_trigger
	cooldown_circle.progress.value = 0.0
	
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	
	queue_redraw()
	if current_state == default_movement:
		wander_update(delta)
	elif current_state == chase_movement:
		chase_update(delta)
		cooldown_circle.visible = false
	else:
		cooldown_circle.visible = false

func wander_update(delta: float) -> void:
	if frozen:
		trigger_timer = 0.0
		cooldown_circle.visible = false
		return
	
	if distance_to_player < detection_radius:
		if trigger_timer > time_to_trigger:
			trigger()
		trigger_timer += delta
		cooldown_circle.visible = true
	else:
		trigger_timer = 0.0
		cooldown_circle.visible = false
		
	cooldown_circle.progress.value = trigger_timer

func trigger():
	set_state(teleport_movement)
	sprite.play("triggered")
	
	var audio_data = AudioData.new(scream_sound, global_position)
	AudioManager.play_sound(audio_data)
	
	await get_tree().create_timer(time_to_teleport).timeout
	
	if frozen || current_state != teleport_movement:
		set_state(default_movement)
		return
	
	current_state.teleport()
	sprite.play("appear")
	
	var appear_data = AudioData.new(appear_sound, global_position)
	AudioManager.play_sound(appear_data)
	
	start_chasing()

func chase_update(delta: float) -> void:
	pass
	
func start_chasing():
	set_state(chase_movement)
	
	chase_timer.start()
	#ATTACK IS GOOD BUT VERY STRONG, MAYBE MAKE IT LESS ACCURATE THE FASTER THE PLAYER MOVES
	attacks[0].automatic = true


func teleport_back() -> void:
	
	detection_radius = 0.0
	
	attacks[0].automatic = false
	
	chase_movement.reset_speed_over_time()
	
	set_state(teleport_movement)
	
	sprite.play("disappear")

	var audio_data = AudioData.new(disappear_sound, global_position)
	AudioManager.play_sound(audio_data)
	
	await get_tree().create_timer(1.0).timeout
	
	if current_state != teleport_movement:
		return
	
	current_state.teleport(false)
	
	sprite.play("appear")
	
	var appear_data = AudioData.new(appear_sound, global_position)
	AudioManager.play_sound(appear_data)
	
	is_on_cooldown = true
	await get_tree().create_timer(cooldown).timeout
	is_on_cooldown = false
	
	var tween = create_tween()
	tween.tween_property(self, "detection_radius", initial_radius, 0.25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.play()
	
	set_state(default_movement)
	#sprite.play("default")

func _on_chase_timer_timeout() -> void:
	if current_state == chase_movement:
		teleport_back()

func set_sprite_direction():
	if !updating_direction:
		return
	
	if current_state == default_movement:
		if linear_velocity.x < 0:
			sprite.scale.x = 1
		elif linear_velocity.x > 0:
			sprite.scale.x = -1
		return
	else:
		if sprite.animation == "attack":
			sprite.scale.x = 1
			if sprite.rotation_degrees > 90 || sprite.rotation_degrees < -90:
				sprite.flip_v = true
			else:
				sprite.flip_v = false
			sprite.flip_h = true
			sprite.rotation = get_angle_to(player.global_position)
			return
	
	sprite.flip_v = false
	sprite.flip_h = false
	sprite.rotation_degrees = 0
	
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

func on_damaged(damage_data):
		
	if current_state == default_movement:
		trigger()
	else:
		if attacks[0].is_in_attack_sequence:
			health_manager.break_armor()
	
	super.on_damaged(damage_data)

func _draw() -> void:
	if current_state != default_movement && !is_on_cooldown:
		return
	
	draw_circle(Vector2(), detection_radius, circle_color)
	DrawUtils.draw_empty_circle(self, Vector2(), detection_radius, circle_outline_color, 32.0, 1.5, 0.0)


func _on_sprite_animation_finished() -> void:
	if sprite.animation == "triggered":
		sprite.play("disappear")
		var audio_data = AudioData.new(disappear_sound, global_position)
		AudioManager.play_sound(audio_data)
	elif sprite.animation == "appear":
		if current_state == chase_movement:
			sprite.play("chase_loop")
		if current_state == teleport_movement:
			sprite.play("default")
	elif sprite.animation == "attack":
		if current_state == chase_movement:
			sprite.play("chase_loop")
		if current_state == default_movement:
			sprite.play("default")

func _on_close_range_attack_attack_started() -> void:
	sprite.play("attack")
	var audio_data = AudioData.new(attack_sound, global_position)
	AudioManager.play_sound(audio_data)


func _on_sprite_frame_changed() -> void:
	var chasing: bool = sprite.animation == "chase_loop"
	if sprite.animation == "default" || chasing:
		if sprite.frame == 1:
			var audio_data = AudioData.new(wing_flap_sound_2, global_position)
			audio_data.max_distance = 512
			audio_data.attenuation = 1.25
			if chasing:
				audio_data.pitch = 1.2
			AudioManager.play_sound(audio_data)
		elif sprite.frame == 4:
			var audio_data = AudioData.new(wing_flap_sound_1, global_position)
			audio_data.max_distance = 512
			audio_data.attenuation = 1.25
			if chasing:
				audio_data.pitch = 1.2
			AudioManager.play_sound(audio_data)


func _on_close_range_attack_attack_performed() -> void:
	var audio_data = AudioData.new(melee_sound, global_position)
	AudioManager.play_sound(audio_data)


func _on_status_effects_manager_effect_removed(effect) -> void:
	if effect == "freeze":
		teleport_back()
