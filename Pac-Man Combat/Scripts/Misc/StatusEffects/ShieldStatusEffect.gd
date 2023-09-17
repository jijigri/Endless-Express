extends StatusEffect

var effect: Sprite2D

var shield_scale: Vector2

var shield_health: float = 80
var current_health: float = 0

func _initiated():
	super._initiated()
	
	current_health = shield_health
	
	if entity_owner.health_manager != null:
		entity_owner.health_manager.damage_tanked.connect(_on_damage_tanked)
	
	effect = $Effect
	
	var size = entity_owner.hurtbox.collision_shape.shape.size
	var effect_scale = (1.0 / 256.0) * (size.x + 16.0)
	
	shield_scale = Vector2.ONE * effect_scale
	
	print_debug("SIZE: ", effect_scale)
	
	effect.visible = true
	effect.scale = Vector2.ZERO
	
	var tween = create_tween()
	tween.tween_property(effect, "scale", shield_scale, 0.1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	entity_owner.health_manager.invincible = true

func _on_damage_tanked(damage_data: DamageData):
	if active:
		current_health -= damage_data.damage
		if current_health <= 0:
			disable_effect()
		
		var tween = create_tween()
		tween.tween_property(effect, "scale", shield_scale * 1.5, 0.075)
		tween.tween_property(effect, "scale", shield_scale, 0.075)

func disable_effect(called_from_manager: bool = false):
	
	if !active:
		return
	
	var tween = create_tween()
	tween.tween_property(effect, "scale", Vector2.ZERO, 0.1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN)
	tween.tween_callback(effect.set_deferred.bind("visible", false))

	entity_owner.health_manager.invincible = false
	
	super.disable_effect(called_from_manager)

