extends Area2D

@export var move_speed: float = 800
@export var damage: float = 20
@export var armor_break_time: float = 2.0
@export var knockback_force: float = 40

@export var explosion_scene: PackedScene

var velocity: Vector2

var current_speed = 300

func _ready() -> void:
	var tween = create_tween()
	tween.tween_property(self, "current_speed", move_speed, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	
	await get_tree().create_timer(5.0).timeout
	destroy()

func _process(delta: float) -> void:
	velocity = transform.x
	global_translate(velocity * current_speed * delta)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Solid"):
		spawn_explosion()
		destroy()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Hurtbox"):
		if area.has_method("receive_hit"):
			spawn_explosion()
			
			var damageData = DamageData.new(damage, global_position, velocity * knockback_force)
			damageData.source = self
			area.receive_hit(damageData)
			on_entity_damaged(area)
			
			if area.status_effects_manager != null:
				area.status_effects_manager.set_status_effect("stagger", armor_break_time)
			
		destroy()

func spawn_explosion() -> void:
	var instance = Global.spawn_object(explosion_scene, global_position)
	instance.initialize(16.0, 0, armor_break_time)
	instance.player_push_force = 0.0

func on_entity_damaged(area: Area2D):
	pass

func destroy() -> void:
	queue_free()
