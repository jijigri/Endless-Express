extends Sprite2D

var lifetime = 0.1

func set_color(color: Color):
	material.set_shader_parameter("color", color)

func _ready() -> void:
	#material.set_shader_parameter("strength", 0)
	
	var shader_tween = create_tween()
	shader_tween.tween_method(fade_shader, 0.0, 1.0, lifetime * 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	shader_tween.play()
	
	var tween = create_tween()
	tween.tween_method(fade_out, 1.0, 0.0, lifetime).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(queue_free)
	tween.play()

func fade_out(value):
	modulate.a = value
	

func fade_shader(value):
	if material.get_shader_parameter("strength") < 1:
		material.set_shader_parameter("strength", value)
