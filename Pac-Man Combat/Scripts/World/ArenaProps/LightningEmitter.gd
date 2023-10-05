@tool
extends Area2D

@export_range(48, 512, 16, "or_greater") var height: int = 48: set = set_height

var damage = 40.0
var time_between_strikes = 4.0
var warmup_time = 1.5

@export var collision_shape: CollisionShape2D
@export var sprite: NinePatchRect
@export var animator: AnimationPlayer

@onready var time_left = time_between_strikes

var triggered_sound = preload("res://Audio/SoundEffects/ArenaProps/LightningEmitter/LightningEmitterTriggered.wav")
var strike_sound = preload("res://Audio/SoundEffects/ArenaProps/LightningEmitter/LightningEmitterStrike.wav")

func set_height(value):
	height = value
	if collision_shape != null:
		update_shape()

func update_shape():
	if collision_shape != null:
		collision_shape.shape.size = Vector2(6, height)
	
	if sprite != null:
		sprite.size = Vector2(32.0, height)
		sprite.position = Vector2(-sprite.size.x / 2, -sprite.size.y / 2)

func _ready() -> void:
	if Engine.is_editor_hint() == false:
		collision_shape = $CollisionShape2D
		sprite = $NinePatchRect
		animator = $AnimationPlayer
		
		update_shape()
	else:
		collision_shape = $CollisionShape2D
		collision_shape.shape = collision_shape.shape.duplicate()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if animator.current_animation == "default":
		time_left -= delta
		if time_left <= 0.0:
			var audio_data = AudioData.new(triggered_sound, global_position)
			audio_data.pitch = 0.5 / warmup_time
			audio_data.max_distance = 460
			AudioManager.play_in_player(audio_data, "lightning", 3)
			
			play_warmup()
			
			time_left = time_between_strikes

func play_warmup():
	var anim_time = 0.5
	var speed_scale = anim_time * 2 / warmup_time
	animator.speed_scale = speed_scale
	animator.play("warmup")

func strike():
	animator.play("strike")
	
	await get_tree().create_timer(0.2).timeout
	
	var audio_data = AudioData.new(strike_sound, global_position)
	audio_data.pitch = randf_range(0.9, 1.2)
	audio_data.max_distance = 512
	AudioManager.play_in_player(audio_data, "lightning", 3, true)
	
	if get_overlapping_areas().size() > 0:
		
		for hit in get_overlapping_areas():
			if hit.is_in_group("Hurtbox"):
				if hit.has_method("receive_hit"):
					if hit.has_meta("isPlayer"):
						var damageData = DamageData.new(damage, global_position, Vector2())
						damageData.source = self
						hit.receive_hit(damageData)
					else:
						var damageData = DamageData.new(20.0, global_position, Vector2(), 0.5)
						damageData.source = self
						hit.receive_hit(damageData)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if Engine.is_editor_hint():
		return
	
	if anim_name == "warmup":
		animator.speed_scale = 1.0
		strike()
	elif anim_name == "strike":
		animator.play("default")
