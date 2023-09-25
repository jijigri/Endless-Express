extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var simple_movement: SimpleObjectMovement = $SimpleObjectMovement

var player = null
var active: bool = true

var appear_sound = preload("res://Audio/SoundEffects/ArenaProps/PoppinBalloon/PoppinBalloonAppearSound.wav")
var pop_sound = preload("res://Audio/SoundEffects/ArenaProps/PoppinBalloon/PoppinBalloonPopSound.wav")

func _process(delta: float) -> void:
	if active == false: return
	
	if player != null:
		test_for_player()
	
	if active:
		simple_movement.update_pos(delta)
		global_position = simple_movement.get_pos()

func _on_body_entered(body: Node2D) -> void:
	if active == false: return
	
	if body is Player:
		player = body
		test_for_player()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null

func test_for_player():
	if active == false: return
	
	if player.velocity.y > 0.0:
		sprite.play("disappear")
		player.velocity = Vector2(player.velocity.x, -530)
		player.isJumping = false
		
		var audio_data = AudioData.new(pop_sound, global_position)
		AudioManager.play_sound(audio_data)
		
		active = false
		
		respawn()

func respawn():
	await get_tree().create_timer(5.0).timeout
	sprite.play("appear")
	
	var audio_data = AudioData.new(appear_sound, global_position)
	AudioManager.play_sound(audio_data)
	
	active = true

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "appear":
		sprite.play("default")
