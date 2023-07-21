extends Control

@onready var menu_screen = $CanvasLayer/Menu
@onready var settings_screen = $CanvasLayer/Settings
@onready var character_screen = $CanvasLayer/CharacterSelectionScreen

@onready var button_pressed_player: AudioStreamPlayer2D = $ButtonPressedPlayer

func _ready() -> void:
	settings_screen.back_button.pressed.connect(_on_back_pressed)
	HUD.visible = false
	set_screen(0)
	

func _on_play_button_pressed() -> void:
	set_screen(2)
	button_pressed_player.stream = preload("res://Audio/SoundEffects/UI/PlayButtonPressedSound.wav")
	button_pressed_player.play()
	set_player_name()

func _on_settings_button_pressed() -> void:
	set_screen(1)
	
	button_pressed_player.play()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
	
	button_pressed_player.play()

func _on_back_pressed() -> void:
	set_screen(0)
	
	button_pressed_player.play()

func set_screen(index):

	if index == 0:
		set_screen_visibility(true, false, false)
	elif index == 1:
		set_screen_visibility(false, true, false)
	elif index == 2:
		set_screen_visibility(false, false, true)

func set_screen_visibility(menu: bool, settings: bool, characters: bool):
	menu_screen.visible = menu
	settings_screen.visible = settings
	character_screen.visible = characters

func set_player_name():
	if LootLocker.authentificated == false:
		await LootLocker.authentification_complete
	
	LootLocker.set_player_name(%DisplayNameEdit.text)
