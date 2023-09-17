extends TargetStateMachine

func _on_sprite_animation_finished() -> void:
	sprite.play("default")
