extends Sprite2D

var duration = 0.5


func _ready() -> void:
	var size_tween = create_tween()
	size_tween.tween_property(material, "shader_parameter/size", 1.0, duration)
	
	var force_tween = create_tween()
	force_tween.tween_property(material, "shader_parameter/force", 0.0, duration)
	
	force_tween.tween_callback(destroy_object)
	
	size_tween.play()
	force_tween.play()

func destroy_object():
	queue_free()

func initialize(duration: float, size: float = 16.0, force: float = 0.1, thickness: float = 0.1):
	scale = Vector2(size, size)
	
	self.duration = duration
	
	material.set_shader_parameter("size", 0.0)
	material.set_shader_parameter("force", force)
	material.set_shader_parameter("thickness", thickness)
