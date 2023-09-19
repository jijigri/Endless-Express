extends CanvasLayer

@onready var confirm_screen = $ConfirmationScreen
@onready var game_manager = get_tree().get_first_node_in_group("GameManager")

var settings = preload("res://Scenes/UI/settings.tscn")

var last_tried_to_restart: bool = true

var settings_instance

func _ready() -> void:
	GameEvents.player_killed.connect(_on_player_killed)
	
	confirm_screen.visible = false
	visible = false

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if game_manager != null:
			if game_manager.game_over:
				if visible:
					close()
				return
		if visible:
			close()
		else:
			visible = true
			Global.pause_menu_enabled = true

func _on_settings_pressed() -> void:
	settings_instance = Global.spawn_object(settings, Vector2(32, 32), 0, self)
	settings_instance.closed.connect(_on_settings_closed)

func _on_settings_closed():
	if settings_instance != null:
		settings_instance.queue_free()

func _on_restart_run_pressed() -> void:
	last_tried_to_restart = true
	confirm_screen.visible = true


func _on_main_menu_pressed() -> void:
	last_tried_to_restart = false
	confirm_screen.visible = true


func _on_cancel_pressed() -> void:
	confirm_screen.visible = false


func _on_confirm_pressed() -> void:
	if last_tried_to_restart:
		game_manager.submit_data()
		MusicHandler.stop_music()
		close()
		Global.load_scene("game")
	else:
		game_manager.submit_data()
		MusicHandler.stop_music()
		close()
		Global.load_scene("main_menu")


func _on_back_pressed() -> void:
	close()

func close():
	_on_settings_closed()
	confirm_screen.visible = false
	visible = false
	Global.pause_menu_enabled = false

func _on_player_killed():
	if visible:
		close()
