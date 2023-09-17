extends Area2D

@export var damage: float = 35.0
@export var speed: float = 1200.0
@export var knockback_force: float = 30.0
@export var armor_break_time: float = 0.0
@export var lifetime: float = 1.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var shape_cast: ShapeCast2D = $ShapeCast

var break_sound = preload("res://Audio/SoundEffects/Abilities/SwapBladeBreak.wav")
var teleport_sound = preload("res://Audio/SoundEffects/Abilities/SwapBladeTeleport.wav")
var hit_sound = preload("res://Audio/SoundEffects/Abilities/SawpBladeHit.wav")

var entities_damaged = []

var velocity: Vector2
var last_valid_position

var active: bool = true

var player: Node2D

func _ready() -> void:
	$Lifetime.wait_time = lifetime
	$Lifetime.start(lifetime)
	shape_cast.shape.size = player.collision_shape.shape.size + Vector2(2, 2)
	#last_valid_position = player.global_position
	
	update_valid_position()
	
	velocity = transform.x


func _physics_process(delta):
	if not active:
		return
	
	shape_cast.target_position = velocity * speed * delta
	global_translate(velocity * speed * delta)
	update_valid_position()

func _on_lifetime_timeout() -> void:
	if active:
		destroy_blade()
		break_blade()

func update_valid_position():
	shape_cast.force_shapecast_update()
	#shape_cast.force_update_transform()
	if shape_cast.is_colliding() == false:
		last_valid_position = global_position
	else:
		print_debug("Colliding!")

func _on_area_entered(area: Area2D) -> void:
	if not active:
		return
	
	if area is Bullet:
		return
	
	if area.is_in_group("Hurtbox"):
			if entities_damaged.has(area):
				return
			else:
				entities_damaged.append(area)
			
			var damageData = DamageData.new(damage, global_position, velocity * knockback_force, armor_break_time)
			damageData.source = self
			area.receive_hit(damageData)
			on_entity_damaged(area)
			
			#destroy_blade()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Hurtbox"):
		if entities_damaged.has(body):
			return
		else:
			entities_damaged.append(body)
		
		var damageData = DamageData.new(damage, global_position, velocity * knockback_force, armor_break_time)
		damageData.source = self
		body.receive_hit(damageData)
		on_entity_damaged(body)
		
		#destroy_blade()

func break_blade():
	sprite.play("disappear")
	teleport_player()
	var audio_data = AudioData.new(break_sound, global_position)
	AudioManager.play_sound(audio_data)

func on_entity_damaged(area):
	return
	active = false
	
	sprite.play("hit")
	
	var audio_data = AudioData.new(hit_sound, global_position)
	audio_data.max_distance = 2600.0
	AudioManager.play_sound(audio_data)
	
	var area_pos = area.global_position
	
	teleport_enemy(area)
	
	teleport_player()


func teleport_enemy(area):
	var rigidbody = area.get_parent()
	if rigidbody.is_in_group("Enemies"):
		#rigidbody.global_position = player.global_position
		var tween = create_tween()
		tween.tween_property(rigidbody, "global_position", player.global_position, 0.05)
		tween.play()

func teleport_player():
	var pos: Vector2
	if last_valid_position != null:
		pos = last_valid_position
	else:
		print_debug("Not teleporting")
		return
	
	
	var teleport_audio_data = AudioData.new(teleport_sound, player.global_position)
	teleport_audio_data.max_distance = 2600.0
	AudioManager.play_sound(teleport_audio_data)
	
	var direction: Vector2 = player.global_position.direction_to(pos).normalized()
	
	var tween = create_tween()
	tween.tween_property(player, "global_position", pos, 0.1)
	tween.tween_callback(player_teleport_end.bind(direction))
	tween.play()
	
	CameraManager.shake(4.0, 0.15)
	CameraManager.zoom_in(-0.08, 0.1)

func player_teleport_end(direction: Vector2):
	player.velocity.x = direction.x * 250.0
	player.velocity.y = direction.y * 400.0

func destroy_blade():
	active = false
	$GhostTrail.enabled = false
	await get_tree().create_timer(2.0).timeout
	queue_free()


func _on_solid_collisions_body_entered(body: Node2D) -> void:
	if body.is_in_group("Solid") && !body.is_in_group("Platform"):
		destroy_blade()
		break_blade()
