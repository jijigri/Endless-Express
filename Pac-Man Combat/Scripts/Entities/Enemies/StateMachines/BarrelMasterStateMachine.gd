extends ChaserStateMachine

@export var max_distance_from_player: float = 512
@export var cooldown_time: float = 4.0
@export var barrel_throw_time: float = 1.0

@onready var raycast: RayCast2D = $RayCast2D
@onready var cooldown: Timer = $Cooldown

@onready var warmup_sound = preload("res://Audio/SoundEffects/Enemies/BarrelMaster/BarrelMasterWarmupSound.wav")
@onready var throw_sound = preload("res://Audio/SoundEffects/Enemies/BarrelMaster/BarrelMasterThrowSound.wav")

var can_throw_barrel: bool = true

func _process(delta: float) -> void:
	super._process(delta)

	if distance_to_player > max_distance_from_player:
		return
	
	if can_throw_barrel:
		var direction_to_player: Vector2 = global_position.direction_to(player.global_position).normalized()
		var length = clamp(distance_to_player, 64, max_distance_from_player)
		
		raycast.target_position = direction_to_player * length

		if raycast.is_colliding() == false:
			check_player_position(direction_to_player)

func check_player_position(direction_to_player: Vector2) -> void:
	
	var y_dist = player.global_position.y - global_position.y
	
	if y_dist > -2.0 && y_dist < 65.0:
		attack()

func attack() -> void:
	
	if frozen:
		sprite.play("default")
		return
	
	can_throw_barrel = false
	
	current_state.speed_modifiers.append(0.4)
	
	sprite.play("throw_warmup")
	
	var audio_data = AudioData.new(warmup_sound, global_position)
	audio_data.max_distance = 512
	audio_data.attenuation = 0.5
	AudioManager.play_sound(audio_data)
	
	await get_tree().create_timer(barrel_throw_time).timeout
	
	if frozen:
		sprite.play("default")
		return
	
	var direction_to_player: Vector2 = global_position.direction_to(player.global_position).normalized()
	
	sprite.play("throw")
	
	audio_data = AudioData.new(throw_sound, global_position)
	audio_data.max_distance = 800
	audio_data.attenuation = 0.9
	AudioManager.play_sound(audio_data)
	
	await get_tree().create_timer(0.1).timeout
	
	if frozen:
		sprite.play("default")
		return
	
	current_state.speed_modifiers.erase(0.4)
	
	var throw_force = Vector2(420, -150)
	var velocity = Vector2(sign(direction_to_player.x) * throw_force.x, throw_force.y)
	attacks[0].throw(velocity)
	
	cooldown.wait_time = cooldown_time
	cooldown.start()


func _on_cooldown_timeout() -> void:
	can_throw_barrel = true


func _on_sprite_animation_finished() -> void:
	if sprite.animation == "throw_warmup":
		sprite.play("throw_loop")
	elif sprite.animation == "throw":
		sprite.play("default")
