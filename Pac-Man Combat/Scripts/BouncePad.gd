extends Area2D

@export var bounce_velocity = Vector2(0, 50)
@export var only_on_key_press: bool = false
@export var muted: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var player_on: bool = false
var player: Player

var can_bounce: bool = true

signal bounced

func _ready() -> void:
	sprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)

func _process(delta: float) -> void:
	if !can_bounce:
		return

	if player_on:
		var input_valid: bool = false
		if only_on_key_press == false:
			input_valid = Input.is_action_pressed("jump") && !Input.is_action_pressed("interact_cancel")
		
		if input_valid:
			player.velocity = Vector2(player.velocity.x + bounce_velocity.x, bounce_velocity.y)
			sprite.play("jump")
			
			if muted == false:
				AudioManager.play_sound(
					AudioData.new(preload("res://Audio/SoundEffects/Misc/JumpPadSound.wav"),
					global_position)
				)
			
			bounced.emit()
			
			can_bounce = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_on = true
		if player == null:
			body.jumped.connect(on_player_jump)
		player = body
		

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_on = false


func _on_animated_sprite_2d_animation_finished() -> void:
	if can_bounce == false:
		can_bounce = true
	sprite.play("default")

func on_player_jump():
	if only_on_key_press == false:
		return
	
	if player_on:
		player.velocity = Vector2(player.velocity.x + bounce_velocity.x, bounce_velocity.y)
		sprite.play("jump")
		
		if muted == false:
			AudioManager.play_sound(
				AudioData.new(preload("res://Audio/SoundEffects/Misc/JumpPadSound.wav"),
				global_position)
			)
		
		bounced.emit()
		
		can_bounce = false
