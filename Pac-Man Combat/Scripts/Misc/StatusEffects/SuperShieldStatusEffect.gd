extends StatusEffect

var effect: AnimatedSprite2D

func _ready() -> void:
	pass

func _initiated():
	super._initiated()
	
	effect = $Effect
	
	var size = entity_owner.hurtbox.collision_shape.shape.size
	var effect_scale = (1.0 / 256.0) * (size.x + 16.0)
	
	print_debug("SIZE: ", effect_scale)
	
	effect.visible = true
	effect.scale = Vector2.ZERO
	
	var tween = create_tween()
	tween.tween_property(effect, "scale", Vector2.ONE * effect_scale, 0.1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	entity_owner.health_manager.invincible = true

func disable_effect(called_from_manager: bool = false):
	
	if !active:
		return
	
	var tween = create_tween()
	tween.tween_property(effect, "scale", Vector2.ZERO, 0.1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN)
	tween.tween_callback(effect.set_deferred.bind("visible", false))

	entity_owner.health_manager.invincible = false
	
	super.disable_effect(called_from_manager)

