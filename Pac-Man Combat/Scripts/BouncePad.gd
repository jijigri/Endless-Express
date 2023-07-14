extends Area2D

@export var bounce_velocity = Vector2(0, 50)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var player_on: bool = false
var player: Player

var can_bounce: bool = true

func _ready() -> void:
	sprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)

func _process(delta: float) -> void:
	if !can_bounce:
		return

	if player_on:
		if Input.is_action_pressed("jump") && !Input.is_action_pressed("interact_cancel"):
			player.velocity = Vector2(player.velocity.x + bounce_velocity.x, bounce_velocity.y)
			sprite.play("jump")
			
			AudioManager.play_sound(
				AudioData.new(preload("res://Audio/SoundEffects/Misc/JumpPadSound.wav"),
				global_position)
			)
			
			can_bounce = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_on = true
		player = body
		

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_on = false


func _on_animated_sprite_2d_animation_finished() -> void:
	if can_bounce == false:
		can_bounce = true
	sprite.play("default")
