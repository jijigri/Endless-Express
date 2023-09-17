class_name SpeedBooster
extends Area2D

@onready var sprite: AnimatedSprite2D = $Sprite2D

var player: PlayerMovement

var speed_gain: float = 1.0 #used to be 1.6
var gain_time: float = 2.5

var is_player_on: bool = false

var cooldown_time: float = 8.0
var current_cooldown: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D):
	if body is PlayerMovement:
		if player == null:
			player = body
		is_player_on = true

func _on_body_exited(body: Node2D):
	if body is PlayerMovement:
		is_player_on = false

func _process(delta: float) -> void:
	if current_cooldown <= 0:
		if is_player_on:
			if player != null:
				player.modify_speed(speed_gain, gain_time)
				current_cooldown = cooldown_time
				
				var icon = Global.spawn_object(ScenesPool.cooldown_circle, Vector2.ZERO, 0, self)
				icon.set_cooldown(cooldown_time)
				
				sprite.play("use")
				
				var audio_data = AudioData.new(preload("res://Audio/SoundEffects/ArenaProps/SpeedBoosterUsed.wav"), global_position)
				#AudioManager.play_sound(audio_data)
	else:
		current_cooldown -= delta
		if current_cooldown <= 0:
			on_cooldown_end()

func on_cooldown_end():
	sprite.play("default")
