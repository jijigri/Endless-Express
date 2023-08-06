extends Control


func _on_play_button_pressed() -> void:
	var result = get_tree().change_scene_to_file("res://Scenes/game.tscn")
	if result != OK:
		print_debug("LOAD SCENE FAILURE ", result)
