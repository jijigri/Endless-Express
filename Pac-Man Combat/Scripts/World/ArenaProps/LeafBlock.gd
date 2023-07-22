@tool
class_name LeafBlock
extends Resizer

@onready var area_shape: CollisionShape2D = $DetectionArea/CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var particles: GPUParticles2D = $Particles
@onready var player = get_tree().get_first_node_in_group("Player")

@onready var default_sprite_pos = sprite.position

@onready var wobble_sound = preload("res://Audio/SoundEffects/ArenaProps/LeafBlocks/LeafBlockWobbleSound.wav")
@onready var break_sound = preload("res://Audio/SoundEffects/ArenaProps/LeafBlocks/LeafBlockBreakSound.wav")

var is_breaking: bool = false
var active: bool = true

var disabled_player_collisions: bool = false

signal broke

func _ready() -> void:
	if Engine.is_editor_hint() == false:
		navigation_region.set_deferred("enabled", false)
	
	sprite = $NinePatchRect
	collision_shape = $CollisionShape2D
	navigation_region = $NavigationRegion2D
	collision_shape.shape = collision_shape.shape.duplicate()
	area_shape.shape = area_shape.shape.duplicate()
	sprite.texture = sprite.texture.duplicate()
	particles.process_material = particles.process_material.duplicate()

func _process(delta: float) -> void:
	super._process(delta)
	
	if !active:
		return
	
	if player != null:
		if !disabled_player_collisions:
			if(abs(player.velocity.x) >= 700.0):
				var dist_y = player.global_position.y - global_position.y
				if dist_y < 0:
					if dist_y < -collision_shape.shape.size.y / 2:
						return
				disabled_player_collisions = true
				collision_shape.set_deferred("disabled", true)
		else:
			if(abs(player.velocity.x) < 700.0):
				disabled_player_collisions = false
				collision_shape.set_deferred("disabled", false)

func _on_detection_area_body_entered(body: Node2D) -> void:
	disable_block()

func receive_hit(damage_data: DamageData):
	if active:
		if damage_data.source is Bullet:
			if damage_data.source.player_owned:
				if damage_data.damage > 50:
					is_breaking = true
					destroy()
				else:
					disable_block()

func disable_block() -> void:
	
	if disabled_player_collisions && active:
		animation_player.stop()
		is_breaking = true
		destroy()
		return
	
	if is_breaking || !active:
		return
	
	is_breaking = true
	animation_player.play("break")

func set_editor_size():
	super.set_editor_size()
	area_shape.shape.size = collision_shape.shape.size + Vector2(8, 8)
	area_shape.position = collision_shape.position
	
	if particles == null:
		particles = $Particles
	
	particles.process_material.emission_box_extents = Vector3(collision_shape.shape.size.x / 2, collision_shape.shape.size.y / 2, 1)
	particles.amount = 0.02 * (collision_shape.shape.size.x * collision_shape.shape.size.y)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if Engine.is_editor_hint():
		return
	
	if anim_name == "break" && active:
		destroy()

func wobble() -> void:
	if Engine.is_editor_hint():
		return
	
	particles.restart()
	
	var audio_data = AudioData.new(wobble_sound, global_position)
	AudioManager.play_sound(audio_data)
	
	var tween = create_tween()
	tween.tween_method(wobble_method, 1.0, 0.0, 0.08)
	tween.play()

func wobble_method(value: float):
	Global.wobble(sprite, default_sprite_pos, value, 3.0)

func destroy():
	if Engine.is_editor_hint():
		return
	
	animation_player.stop()
	
	collision_shape.set_deferred("disabled", true)
	sprite.visible = false
	navigation_region.set_deferred("enabled", true)
	
	particles.amount *= 2.5
	particles.lifetime *= 2
	particles.restart()
	
	var audio_data = AudioData.new(break_sound, global_position)
	AudioManager.play_sound(audio_data)
	
	broke.emit()
	
	active = false
