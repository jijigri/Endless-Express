extends Control

@onready var display_type: OptionButton = %DisplayType
@onready var master_volume = %MasterVolume
@onready var fx_volume = %FXVolume
@onready var music_volume = %MusicVolume
@onready var ambience_volume = %AmbienceVolume
@onready var back_button = %BackButton

signal closed

func _ready() -> void:
	load_settings()
	set_settings()

func load_settings() -> void:
	var config = ConfigFile.new()
	
	var err = config.load("user://settings.cfg")
	
	if err != OK:
		set_default_values()
		print_debug("No settings file found, assigning default values")
		return
	
	display_type.select(config.get_value("display", "display_type", 0))
	master_volume.value = config.get_value("audio", "master_volume", -15)
	fx_volume.value = config.get_value("audio", "fx_volume", 0)
	music_volume.value = config.get_value("audio", "music_volume", 0)
	ambience_volume.value = config.get_value("audio", "ambience_volume", 0)
	
func save_settings() -> void:
	var config = ConfigFile.new()
	
	config.set_value("display", "display_type", display_type.get_selected_id())
	config.set_value("audio", "master_volume", master_volume.value)
	config.set_value("audio", "fx_volume", fx_volume.value)
	config.set_value("audio", "music_volume", music_volume.value)
	config.set_value("audio", "ambience_volume", ambience_volume.value)
	
	config.save("user://settings.cfg")

func set_default_values() -> void:
	display_type.select(0)
	master_volume.value = -15
	fx_volume.value = 0
	music_volume.value = 0
	ambience_volume.value = 0

func set_settings() -> void:
	_on_display_type_item_selected(display_type.get_selected_id())
	_on_master_volume_value_changed(master_volume.value)
	_on_fx_volume_value_changed(fx_volume.value)
	_on_music_volume_value_changed(music_volume.value)
	_on_ambience_volume_value_changed(ambience_volume.value)

func _on_display_type_item_selected(index: int) -> void:
	if index == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif index == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

func _on_master_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)


func _on_fx_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(3, value)


func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, value)


func _on_ambience_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, value)


func _on_back_button_pressed() -> void:
	save_settings()
	closed.emit()
