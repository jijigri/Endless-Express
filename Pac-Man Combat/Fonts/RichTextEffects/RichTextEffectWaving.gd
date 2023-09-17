@tool
extends RichTextEffect
class_name RichTextWaving

var bbcode := "waving"

var size: int = 0

@export var time: float = 0.0

func get_text_server():
	return TextServerManager.get_primary_interface()

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var speed = char_fx.env.get("speed", 5.0)
	var amp = char_fx.env.get("amp", 10.0)
	
	if char_fx.relative_index > size:
		size = char_fx.relative_index + 1
	
	var offset: Vector2 = Vector2()
	var latency = 1 - char_fx.relative_index - 1
	#var divider = (latency / speed) / ((size - 1) * speed)
	
	var displacement = (latency / speed)
	var dist = (size - 1) / speed
	
	var time_clamped = clamp(time, 0, 1)
	
	var time_offset = clamp((time * (dist + 1)) + displacement, 0, 1.0) * PI
	
	offset.y = -sin(time_offset) * amp
	
	char_fx.offset = offset
	
	return true
