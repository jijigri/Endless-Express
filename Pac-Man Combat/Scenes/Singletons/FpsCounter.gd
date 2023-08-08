extends Label

func _process(delta: float) -> void:
	
	visible = Global.debug_mode
	
	set_text(str(Engine.get_frames_per_second()))
