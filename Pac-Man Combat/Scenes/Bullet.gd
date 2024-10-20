class_name Bullet
extends Area2D

@export var has_piercing: bool = false
@export var break_armor: float = 0.0

@export_group("Status Effect")
@export var status_effect: String = ""
@export var status_time: float = 0.0
@export var status_cap: int = 0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var particles: GPUParticles2D = $Particles

var knockback_force: float = 10
var damage: float
var speed: float
var velocity: Vector2
var lifetime: float

var entities_damaged = []

var gun_origin

var player_owned: bool = false

var active: bool = true


func _ready() -> void:
	$Lifetime.wait_time = lifetime
	$Lifetime.start(lifetime)

func _physics_process(delta):
	if not active:
		return
		
	global_translate(velocity * speed * delta)
	pass

func initialize(_damage: float, _speed: float, _knockback_force: float = 0, _lifetime = 0.5):
	velocity = -transform.y
	damage = _damage
	speed = _speed
	knockback_force = _knockback_force
	lifetime = _lifetime

func set_team(team_player: bool):
	if team_player:
		set_collision_mask_value(1, false)
		set_collision_mask_value(2, true)
	else:
		set_collision_mask_value(1, true)
		set_collision_mask_value(2, false)
		team_player = false
	
	player_owned = team_player

func _on_lifetime_timeout() -> void:
	if active:
		destroy_bullet()

func _on_area_entered(area: Area2D) -> void:
	if not active:
		return
	
	if area is Bullet:
		return
	
	if area.is_in_group("Hurtbox"):
		if area.has_method("receive_hit"):
			#if has_piercing:
			if entities_damaged.has(area):
				return
			else:
				entities_damaged.append(area)
				
			
			var damageData = DamageData.new(damage, global_position, velocity * knockback_force, break_armor)
			damageData.source = self
			area.receive_hit(damageData)
			on_entity_damaged(area)
		
		if !has_piercing:
			destroy_bullet()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Hurtbox"):
		#if has_piercing:
		if entities_damaged.has(body):
			return
		else:
			entities_damaged.append(body)
				
			
		var damageData = DamageData.new(damage, global_position, velocity * knockback_force)
		damageData.source = self
		body.receive_hit(damageData)
		on_entity_damaged(body)
		
		if !has_piercing:
			destroy_bullet()
	
	elif body.is_in_group("Solid") && !body.is_in_group("Platform"):
		destroy_bullet()

func on_entity_damaged(area):
	if !has_piercing:
		active = false
	
	
	if gun_origin != null:
		if gun_origin.has_method("on_hit"):
			gun_origin.on_hit()
	
	if status_effect != "" && status_time > 0:
		if area.get("status_effects_manager"):
			if status_cap > 0:
				if area.status_effects_manager.number_of_effects(status_effect) >= status_cap:
					return
			
			area.status_effects_manager.set_status_effect(status_effect, status_time)

func destroy_bullet():
	active = false
	sprite.play("disappear")
	await get_tree().create_timer(0.1).timeout
	particles.emitting = false
	await get_tree().create_timer(2.0).timeout
	queue_free()
