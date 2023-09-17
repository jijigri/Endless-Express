extends StaticBody2D

var active: bool = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if active:
		Global.load_scene("game")
		active = false
