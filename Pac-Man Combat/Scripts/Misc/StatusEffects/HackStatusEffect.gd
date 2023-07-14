extends StatusEffect

var effect: Sprite2D

func _ready() -> void:
	pass

func _initiated():
	super._initiated()
	
	effect = $Effect
	
	effect.visible = true
	effect.scale = Vector2.ZERO
	
	var tween = create_tween()
	tween.tween_property(effect, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	entity_owner.health_manager.invincible = true

func disable_effect(called_from_manager: bool = false):
	
	var tween = create_tween()
	tween.tween_property(effect, "scale", Vector2.ZERO, 0.1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN)
	tween.tween_callback(effect.set_deferred.bind("visible", false))

	entity_owner.health_manager.invincible = false
	
	super.disable_effect(called_from_manager)

