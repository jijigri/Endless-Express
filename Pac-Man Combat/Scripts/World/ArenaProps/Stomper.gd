@tool
extends StaticBody2D

@export var open_time: float = 5.0
@export var cooldown_time: float = 5.0
@export var closing_time: float = 0.25
@export var effects_delay: float = 0.15

@onready var sprite: NinePatchRect = $Sprite
@onready var navigation_region: NavigationRegion2D = $NavigationRegion2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var player_collision_damage: CollisionDamage = $PlayerCollisionDamage
@onready var enemy_collision_damage: CollisionDamage = $EnemyCollisionDamage
@onready var initial_sprite_position = sprite.position
@onready var health_manager = $HealthManager
@onready var buttons: Node2D = $Buttons

@onready var hurtbox1 = $Buttons/Button1/Hurtbox
@onready var hurtbox2 = $Buttons/Button2/Hurtbox

@onready var sprite1 = $Buttons/Button1/Sprite2D
@onready var sprite2 = $Buttons/Button2/Sprite2D

@onready var timer: Timer = $Timer

@onready var countdown_sound: AudioStreamPlayer2D = $CountdownPlayer

var is_closed: bool = true
var is_on_cooldown: bool = false

var countdown_index: int = 0

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		set_editor_size()
	else:
		if is_closed == false:
			if timer.time_left < 3.0 - closing_time / 2 && countdown_index == 0:
				countdown_index += 1
				countdown_sound.play()
			elif timer.time_left < 2.0 - closing_time / 2 && countdown_index == 1:
				countdown_index += 1
				countdown_sound.play()
			elif timer.time_left < 1.0 - closing_time / 2 && countdown_index == 2:
				countdown_index += 1
				countdown_sound.play()

func set_editor_size():
	if navigation_region == null:
		navigation_region = $NavigationRegion2D
		
	if collision_shape == null:
		collision_shape = $CollisionShape2D
	
	if player_collision_damage == null:
		player_collision_damage = $CollisionDamage
	
	if enemy_collision_damage == null:
		enemy_collision_damage = $CollisionDamage
	
	var size: Vector2 = collision_shape.shape.size
	var center: Vector2 = collision_shape.position
	
	var polygon = NavigationPolygon.new()
	var outline = PackedVector2Array([
		center + Vector2(-size.x / 2, -size.y / 2),
		center + Vector2(-size.x / 2, size.y / 2),
		center + Vector2(size.x / 2, size.y / 2),
		center + Vector2(size.x / 2, -size.y / 2)
		])
	polygon.add_outline(outline)
	polygon.make_polygons_from_outlines()
	navigation_region.navigation_polygon = polygon
	
	var shape = player_collision_damage.get_node("Area2D/CollisionShape2D")
	shape.position = collision_shape.position
	shape.shape.size = collision_shape.shape.size - Vector2(4, 0)
	
	shape = enemy_collision_damage.get_node("Area2D/CollisionShape2D")
	shape.position = collision_shape.position
	shape.shape.size = collision_shape.shape.size

func close():
	is_closed = true
	
	navigation_region.enabled = false
	
	set_on_cooldown()
	
	var final_sprite_position = initial_sprite_position
	var tween = create_tween()
	tween.tween_property(sprite, "position", final_sprite_position, closing_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_callback(on_close_animation_finish)
	tween.play()
	
	var audio_data = AudioData.new(preload("res://Audio/SoundEffects/ArenaProps/Stomper/StomperOpenSound.wav"), global_position)
	AudioManager.play_sound(audio_data)
	
	play_stomp_effects()
	
	await get_tree().create_timer(closing_time / 2).timeout
	damage_enemies()
	test_for_player()
	

func play_stomp_effects():
	await get_tree().create_timer(effects_delay).timeout
	CameraManager.shake(3.0, 0.165)
	var audio_data = AudioData.new(preload("res://Audio/SoundEffects/ArenaProps/Stomper/StomperCloseSound.wav"), global_position)
	AudioManager.play_sound(audio_data)

func open():
	is_closed = false
	
	collision_shape.set_deferred("disabled", true)
	navigation_region.enabled = true
	
	hurtbox1.collision_shape.set_deferred("disabled", true)
	hurtbox2.collision_shape.set_deferred("disabled", true)
	
	disable_buttons()
	
	timer.wait_time = open_time
	timer.start()
	
	var circle = Global.spawn_object(ScenesPool.cooldown_circle, Vector2.ZERO, 0, self)
	circle.set_cooldown(open_time)
	
	var final_sprite_position = initial_sprite_position - Vector2(0, collision_shape.shape.size.y)
	var tween = create_tween()
	tween.tween_property(sprite, "position", final_sprite_position, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.play()
	
	var audio_data = AudioData.new(preload("res://Audio/SoundEffects/ArenaProps/Stomper/StomperOpenSound.wav"), global_position)
	AudioManager.play_sound(audio_data)
	
	countdown_index = 0

func set_on_cooldown():
	is_on_cooldown = true
	timer.wait_time = cooldown_time
	timer.start()
	
	var circle1 = Global.spawn_object(ScenesPool.cooldown_circle, hurtbox1.global_position - global_position, 0, self)
	circle1.set_cooldown(cooldown_time)
	
	var circle2 = Global.spawn_object(ScenesPool.cooldown_circle, hurtbox2.global_position - global_position, 0, self)
	circle2.set_cooldown(cooldown_time)

func on_cooldown_end():
	is_on_cooldown = false
	
	enable_buttons()
	
	hurtbox1.collision_shape.set_deferred("disabled", false)
	hurtbox2.collision_shape.set_deferred("disabled", false)
	
	var audio_data = AudioData.new(preload("res://Audio/SoundEffects/ArenaProps/Stomper/StomperButtonOpen.wav"), global_position)
	AudioManager.play_sound(audio_data)
	

func on_close_animation_finish():
	collision_shape.set_deferred("disabled", false)
	damage_player()

func damage_enemies():

	enemy_collision_damage.check_damage()
	await get_tree().create_timer(0.1).timeout
	enemy_collision_damage.check_damage()
	
func test_for_player():
	if player_collision_damage.area.get_overlapping_bodies().size() < 1:
		collision_shape.set_deferred("disabled", false)

func damage_player():
	player_collision_damage.check_damage()
	await get_tree().create_timer(0.1).timeout
	player_collision_damage.check_damage()
	

func enable_buttons():
	sprite1.play("default")
	sprite2.play("default")

func disable_buttons():
	sprite1.play("close")
	sprite2.play("close")

func _on_health_manager_health_updated(current_health, max_health, damage_data) -> void:
	health_manager.current_health = max_health
	if is_on_cooldown == false:
		if is_closed:
			open()
			var audio_data = AudioData.new(preload("res://Audio/SoundEffects/ArenaProps/Stomper/StomperButtonClose.wav"), global_position)
			AudioManager.play_sound(audio_data)


func _on_timer_timeout() -> void:
	if is_closed == false:
		close()
	elif is_on_cooldown:
		on_cooldown_end()
