extends Camera2D

var current_camera: Camera2D:
	get:
		if current_camera == null:
			enabled = true
			current_camera = self
			print_debug("No camera assigned to CameraManager, resulting to default camera!")
		
		return current_camera
		
	set(value):
		if value != null:
			enabled = false
			current_camera = value

func shake(strength: float, time: float, fade_out: bool = true):
	var t = 0
	while t < time:
		var random_offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
		if fade_out:
			random_offset *= 1 - t
		current_camera.offset = random_offset
		t += get_process_delta_time()
		await get_tree().process_frame
	
	current_camera.offset = Vector2()

func freeze(time: float, time_scale = 0.1):
	Engine.time_scale = time_scale
	await get_tree().create_timer(time * time_scale).timeout
	Engine.time_scale = 1

func zoom_in(value: float, time: float):
	
	var tween = create_tween()
	tween.tween_property(current_camera, "zoom", Vector2.ONE + Vector2(value, value), time / 2).set_ease(Tween.EASE_IN)
	tween.tween_property(current_camera, "zoom", Vector2.ONE, time / 2).set_ease(Tween.EASE_OUT)

func slide(direction: Vector2, in_time: float = 0.1, out_time: float = -1.0):
	if out_time == -1.0:
		out_time = in_time
	
	var tween = create_tween()
	tween.tween_property(current_camera, "offset", direction, in_time)
	tween.tween_property(current_camera, "offset", Vector2(), out_time)
	tween.play()
	await tween.finished
	current_camera.offset = Vector2()
