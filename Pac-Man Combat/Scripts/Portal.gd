class_name Portal
extends Area2D

@export var linked_portal: Portal

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var identifier_icon: Sprite2D = $IdentifierIcon
@onready var solid_collision: CollisionShape2D = $SolidBody/CollisionShape2D
@onready var player = get_tree().get_first_node_in_group("Player")

var late_player_velocity: Vector2

var has_collided_x : bool = false
var has_collided_y : bool = false

var use_cooldown: float = 5.0
var current_cooldown: float = 0.0

var player_on: bool = false

var can_be_used: bool = true

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)
	sprite.animation_finished.connect(_on_animation_finished)
	solid_collision.disabled = true

func _process(delta: float) -> void:
	set_late_velocity()
	
	if player_on:
		on_player_on()
	
	if current_cooldown > 0:
		current_cooldown -= delta
		can_be_used = false
	else:
		if can_be_used == false:
			can_be_used = true
			
			solid_collision.disabled = true
			linked_portal.solid_collision.disabled = true
			
			sprite.play("repair")
			linked_portal.sprite.play("repair")
			
			var audio_data : AudioData = AudioData.new(preload("res://Audio/SoundEffects/Misc/PortalRepaired.wav"),
				global_position)
			audio_data.max_distance = 800
			AudioManager.play_sound(audio_data)
			audio_data.position = linked_portal.position
			AudioManager.play_sound(audio_data)				

func set_late_velocity():
	if player.velocity.x != 0:
		late_player_velocity.x = player.velocity.x
		has_collided_x = false
	else:
		if has_collided_x == false:
			reset_late_velocity_x()
	if player.velocity.y != 0:
		late_player_velocity.y = player.velocity.y
		has_collided_y = false
	else:
		if has_collided_y == false:
			reset_late_velocity_y()

func reset_late_velocity_x():
	has_collided_x = true
	await get_tree().create_timer(0.15).timeout
	if has_collided_x == true:
		late_player_velocity.x = 0

func reset_late_velocity_y():
	has_collided_y = true
	await get_tree().create_timer(0.15).timeout
	if has_collided_y == true:
		late_player_velocity.y = 0

func on_player_on():
	if can_be_used == false:
		return
	
	#if Input.is_action_pressed("move_down"):
		#return
		
	if linked_portal != null:
			teleport_to_linked_portal(player)
			sprite.play("use")
			linked_portal.sprite.play("use")
			
			var audio_data : AudioData = AudioData.new(preload("res://Audio/SoundEffects/Misc/PortalUsed.wav"),
				global_position)
			audio_data.max_distance = 12000
			AudioManager.play_sound(audio_data)
			audio_data.position = linked_portal.position
			AudioManager.play_sound(audio_data)
			
			var icon = Global.spawn_object(ScenesPool.cooldown_circle, Vector2.ZERO, 0, self)
			var icon2 = Global.spawn_object(ScenesPool.cooldown_circle, Vector2.ZERO, 0, linked_portal)
			icon.set_cooldown(use_cooldown)
			icon2.set_cooldown(use_cooldown)
			
func _on_body_entered(body: Node2D) -> void:
	
	if body is PlayerMovement:
		player_on = true

func _on_body_exited(body: Node2D) -> void:
	
	if body is PlayerMovement:
		player_on = false

func teleport_to_linked_portal(body: PlayerMovement):
	var body_velocity: Vector2 = body.velocity
	var portal_direction = linked_portal.transform.x
	
	body.global_position = linked_portal.global_position + (portal_direction * 32)
	if abs(portal_direction.x) > 0.1:
		if portal_direction.x == self.transform.x.x:
			body.velocity.x = -late_player_velocity.x
		else:
			body.velocity.x = late_player_velocity.x
	if abs(portal_direction.y) > 0.1:
		if portal_direction.y == self.transform.x.y:
			body.velocity.y = -late_player_velocity.y
		else:
			body.velocity.y = late_player_velocity.y
	
	current_cooldown = use_cooldown
	linked_portal.current_cooldown = use_cooldown
	
	
	solid_collision.disabled = false
	linked_portal.solid_collision.disabled = false

func _on_animation_finished():
	if sprite.animation == "repair":
		sprite.play("default")
		linked_portal.sprite.play("default")
