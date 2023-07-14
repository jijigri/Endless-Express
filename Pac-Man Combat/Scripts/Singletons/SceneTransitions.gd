extends CanvasLayer

@onready var black_panel : Panel = $BlackPanel

func _ready() -> void:
	black_panel.get_theme_stylebox("panel").bg_color.a = 0
	black_panel.visible = false

func fade_in_out(duration: float = 1.0, delay: float = 0.0) -> void:
	black_panel.visible = true
	var stylebox: StyleBoxFlat = black_panel.get_theme_stylebox("panel")
	stylebox.bg_color.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property(stylebox, "bg_color:a", 1, duration / 2)
	tween.tween_property(stylebox, "bg_color:a", 0, duration / 2).set_delay(delay)
	tween.tween_callback(func(): black_panel.visible = false)
