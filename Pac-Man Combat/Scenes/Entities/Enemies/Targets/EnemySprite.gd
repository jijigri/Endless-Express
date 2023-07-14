extends AnimatedSprite2D

var active = true

func enable():
	active = true
	
func disable():
	active = false

func _on_health_manager_health_updated(current_health, max_health, damage_data) -> void:
	if !active:
		return
	
	blink()
	var tween = create_tween()
	var direction: int = sign(scale.x)
	scale = Vector2.ONE * 1.6 * Vector2(direction, 1)
	tween.tween_property(self, "scale", Vector2.ONE * Vector2(direction, 1), 0.13).set_trans(Tween.TRANS_LINEAR)
	tween.play()

func blink():
	material.set_shader_parameter("flash_modifier", 1.0)
	
	await get_tree().create_timer(.13).timeout
	
	material.set_shader_parameter("flash_modifier", 0.0)
