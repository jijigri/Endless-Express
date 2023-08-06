extends Control

var main_menu: MainMenu

func _on_button_pressed() -> void:
	var name_edit = $Control/DisplayNameEdit
	main_menu.set_player_name(name_edit.text)
	main_menu.display_name_edit.text = name_edit.text
	queue_free()
