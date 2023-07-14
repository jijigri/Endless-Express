extends Control

@onready var progress: TextureProgressBar = $Progress
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
