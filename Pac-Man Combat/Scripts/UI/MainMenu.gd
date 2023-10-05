class_name MainMenu
extends Control

@onready var menu_screen = $CanvasLayer/Menu
@onready var settings_screen = $CanvasLayer/Settings
@onready var character_screen = $CanvasLayer/CharacterSelectionScreen

@onready var update_warning = $CanvasLayer/Menu/UpdateWarning

@onready var display_name_edit = %DisplayNameEdit

@onready var button_pressed_player: AudioStreamPlayer2D = $ButtonPressedPlayer

func _ready() -> void:
	update_warning.visible = false
	
	settings_screen.back_button.pressed.connect(_on_back_pressed)
	HUD.visible = false
	
	$CanvasLayer/Menu/Version.text = "v" + Global.version
	
	set_screen(0)
	
	if LootLocker.online:
		$CanvasLayer/Menu/TestVersionLabel.visible = false
	else:
		$CanvasLayer/Menu/TestVersionLabel.visible = true
	
	var guest_exists = true
	if LootLocker.authentificated:
		guest_exists = LootLocker.guest_exists
	else:
		await LootLocker.authentification_complete
		guest_exists = LootLocker.guest_exists
	
	if guest_exists == false && display_name_edit.text == "Player":
		var box = $CanvasLayer/NameSelectionBox
		box.visible = true
		box.main_menu = self
		#LootLocker.guest_exists = true
	else:
		$CanvasLayer/NameSelectionBox.queue_free()
	
	get_server_version()

func get_server_version():
	var server_version = await LootLocker.get_server_version().get_server_version_complete
	
	if Global.version != server_version:
		update_warning.visible = true

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		if(menu_screen.visible == false):
			set_screen(0)

func _on_play_button_pressed() -> void:
	Global.load_scene("train_station")
	#set_screen(2)
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

func set_player_name(name: String = ""):
	if LootLocker.authentificated == false:
		await LootLocker.authentification_complete
	
	await get_tree().process_frame
	
	if name == "":
		if name != "Player" || name != "player":
			LootLocker.set_player_name(display_name_edit.text)
	else:
		LootLocker.set_player_name(name)


func _on_button_pressed() -> void:
	OS.shell_open("https://discord.gg/gJSYsBntT3")


func _on_survey_button_pressed() -> void:
	OS.shell_open("https://forms.gle/eyxRvw5GmiufLpbK7")


func _on_tutorial_button_pressed() -> void:
	button_pressed_player.stream = preload("res://Audio/SoundEffects/UI/PlayButtonPressedSound.wav")
	button_pressed_player.play()
	set_player_name()
	
	#await get_tree().process_frame
	
	Global.load_scene("tutorial")


func _on_update_warning_pressed() -> void:
	OS.shell_open("https://jijigri.itch.io/endless-express")
