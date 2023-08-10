class_name PlayerGun
extends Node2D

const buffer: float = 0.2

@export var ammo_count: int = 8
@export var ammo_replenish_over_speed = 0.05
@export var ammo_replenish_over_damage = 1.0
@export var spawn_point: Node2D
@export var primary_gun: Gun
@export var secondary_gun: Gun
@export var ammo_bar: HBoxContainer

@onready var sprite: Sprite2D = $Sprite
@onready var outline: Sprite2D = $Sprite/Outline
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var particles: PackedScene = preload("res://Scenes/Effects/drop_particles.tscn")
@onready var current_ammos: int = ammo_count
@onready var small_bullet_icon = preload("res://Scenes/UI/small_bullet_icon.tscn")

var ammo_replenish_value: float = 100.0
var current_ammo_value: float = 0

var current_cooldown = 0

var current_primary_buffer = -1
var current_secondary_buffer = -1

var last_input_primary: bool = true

var last_gun: int = 0

var player_velocity: Vector2

var active: bool = true

func _ready() -> void:
	primary_gun.hit.connect(on_primary_hit)
	set_ammo_bar()

func _process(delta: float) -> void:
	
	set_gun_rotation()
	
	if active:
		get_input()
	
	if current_ammos < ammo_count:
		var last_bullet = ammo_bar.get_child(ammo_bar.get_child_count() - 1)
		last_bullet.progress.max_value = ammo_replenish_value
		last_bullet.progress.value = current_ammo_value
		last_bullet.modulate = Color("5c5c5c")
	
	if current_cooldown > 0:
		current_cooldown -= delta
	
	if current_primary_buffer >= 0:
		current_primary_buffer -= delta
	if current_secondary_buffer >= 0:
		current_secondary_buffer -= delta
		
	
	update_ammo_value(delta * (clamp(abs(player_velocity.x), 10.0, 4000.0) * ammo_replenish_over_speed))

func set_gun_rotation() -> void:
	var mouse_rotation = Helper.angle_between(player.global_position, get_global_mouse_position())
	rotation_degrees = (mouse_rotation)
	if mouse_rotation < -90 || mouse_rotation > 90:
		sprite.flip_v = true
		outline.flip_v = true
	else:
		sprite.flip_v = false
		outline.flip_v = false

func get_input():
	
	if Input.is_action_just_pressed("left_click"):
		last_input_primary = true
		
	elif Input.is_action_just_pressed("right_click"):
		last_input_primary = false
		
	
	if primary_gun != null:
		primary_input()
	
	if secondary_gun != null:
		secondary_input()

func primary_input():
	
	if primary_gun.type == Gun.TYPE.AUTOMATIC:
		if Input.is_action_pressed("left_click"):
			on_primary_pressed()
	elif primary_gun.type == Gun.TYPE.MANUAL:
		if Input.is_action_just_pressed("left_click"):
			if !on_primary_pressed():
				current_primary_buffer = buffer
			else:
				current_primary_buffer = -1
		else:
			if current_primary_buffer >= 0 && last_input_primary:
				on_primary_pressed()

func secondary_input():
	
	if secondary_gun.type == Gun.TYPE.AUTOMATIC:
		if Input.is_action_pressed("right_click"):
			on_secondary_pressed()
	elif secondary_gun.type == Gun.TYPE.MANUAL:
		if Input.is_action_just_pressed("right_click"):
			if !on_secondary_pressed():
				current_secondary_buffer = buffer
			else:
				current_secondary_buffer = -1
		else:
			if current_secondary_buffer >= 0 && !last_input_primary:
				on_secondary_pressed()

func on_primary_pressed() -> bool:
	if current_cooldown <= 0 || (last_gun == 1 && current_cooldown <= secondary_gun.on_switch_cooldown):
		shoot_primary()
		current_cooldown = primary_gun.cooldown
		return true
	
	return false

func on_secondary_pressed() -> bool:
	if current_ammos <= 0:
		
		var audio_data = AudioData.new(preload("res://Audio/SoundEffects/Guns/GunJamSound.wav"), global_position)
		AudioManager.play_sound(audio_data)
		current_secondary_buffer = -1
		
		var tween = create_tween()
		tween.tween_method(shake_clip, 1.0, 0.0, 0.1)
		tween.play()
		
		return false
	
	if current_cooldown <= 0 || (last_gun == 0 && current_cooldown <= primary_gun.on_switch_cooldown):
		shoot_secondary()
		current_cooldown = secondary_gun.cooldown
		return true
	
	return false

func shoot_primary() -> void:
	GameEvents.primary_weapon_shot.emit()
	
	primary_gun.shoot(self)
	
	last_gun = 0
	set_sprite(0.0)

	on_shoot()

func shoot_secondary() -> void:
	GameEvents.secondary_weapon_shot.emit()
	
	secondary_gun.shoot(self)
	
	current_ammos -= 1
	on_ammo_lost()
	
	last_gun = 1
	set_sprite(32.0)

	on_shoot()

func on_shoot():
	pass

func on_primary_hit():
	update_ammo_value(primary_gun.damage * ammo_replenish_over_damage)

func update_ammo_value(value):
	if current_ammos < ammo_count:
		current_ammo_value += value
		if current_ammo_value >= ammo_replenish_value:
			current_ammo_value = current_ammo_value - ammo_replenish_value
			current_ammos += 1
			
			on_ammo_gained()
	else:
		current_ammo_value = 0

func on_ammo_gained():
	update_ammo_bar()

func on_ammo_lost():
	update_ammo_bar(true)

func refill_ammos():
	current_ammos = ammo_count
	current_ammo_value = 0.0
	update_ammo_bar()

func load_ammos(amount: int = 1):
	current_ammos += amount
	if current_ammos > ammo_count:
		current_ammos = ammo_count
	current_ammo_value = 0.0
	update_ammo_bar()

func set_sprite(offset: float) -> void:
	sprite.texture.region.position.x = offset
	outline.texture.region.position.x = offset + 64

func _on_player_moved(velocity) -> void:
	player_velocity = velocity
	

func set_ammo_bar() -> void:
	for i in ammo_count + 1:
		if i >= ammo_count:
			return
		Global.spawn_object(small_bullet_icon, Vector2(), 0, ammo_bar)

func update_ammo_bar(drop: bool = false):
	for c in ammo_bar.get_children():
		if drop && c == ammo_bar.get_child(ammo_bar.get_child_count() - 1):
			c.progress.value = c.progress.max_value
			c.modulate = Color.WHITE
			c.animation_player.play("drop")
		else:
			c.queue_free()
	for i in current_ammos + 1:
		if i >= ammo_count:
			return
		Global.spawn_object(small_bullet_icon, Vector2(), 0, ammo_bar)

func shake_clip(value) -> void:
	var last_bullet = ammo_bar.get_child(ammo_bar.get_child_count() - 1)
	var default_pos = Vector2(5, 12)
	last_bullet.progress.scale = Vector2.ONE + (Vector2.ONE * randf_range(value * 0.2, value * 1.5))
