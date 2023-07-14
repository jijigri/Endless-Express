class_name Bullet
extends Area2D

@export var has_piercing: bool = false

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var particles: GPUParticles2D = $Particles

var knockback_force: float = 10
var damage: float
var speed: float
var velocity: Vector2

var entities_damaged = []

var gun_origin

var active: bool = true

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
	$Lifetime.wait_time = _lifetime

func set_team(team_player: bool):
	if team_player:
		set_collision_mask_value(1, false)
		set_collision_mask_value(2, true)
	else:
		set_collision_mask_value(1, true)
		set_collision_mask_value(2, false)

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
			if has_piercing:
				if entities_damaged.has(area):
					return
				else:
					entities_damaged.append(area)
				
			
			var damageData = DamageData.new(damage, global_position, velocity * knockback_force)
			damageData.source = self
			area.receive_hit(damageData)
			on_entity_damaged(area)
		
		if !has_piercing:
			destroy_bullet()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Solid") && !body.is_in_group("Platform"):
		destroy_bullet()

func on_entity_damaged(area: Area2D):
	if !has_piercing:
		active = false
	
	
	if gun_origin != null:
		if gun_origin.has_method("on_hit"):
			gun_origin.on_hit()

func destroy_bullet():
	active = false
	sprite.play("disappear")
	await get_tree().create_timer(0.1).timeout
	particles.emitting = false
	await get_tree().create_timer(2.0).timeout
	queue_free()
