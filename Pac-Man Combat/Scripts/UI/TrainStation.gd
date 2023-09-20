extends Control

@onready var character_screen = $CharacterScreen
@onready var details_screen = $DetailsScreen
@onready var character_name = $CharacterScreen/Name
@onready var character_description = $CharacterScreen/Description
@onready var play_button = $CharacterScreen/PlayButton
@onready var unlock_button = $CharacterScreen/UnlockButton
@onready var details_button = $CharacterScreen/DetailsButton
@onready var left_button = $CharacterScreen/LeftButton
@onready var right_button = $CharacterScreen/RightButton
@onready var ability_display = $DetailsScreen/AbilityDisplay
@onready var confirm_popup = $UnlockConfirm
@onready var congratulations_popup = $CongratulationsScreen
@onready var confettis = $Confettis

var current_selected_character: int = 0

signal character_unlocked

func _ready() -> void:
	HUD.visible = false
	set_soul_counter()
	set_screen(0)
	swap_selected_character(0)
	
	var ambience = $Ambience
	ambience.volume_db = -20.0
	ambience.playing = true
	var tween = create_tween()
	tween.tween_property(ambience, "volume_db", 0.0, 1.0)
	tween.play()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Global.load_scene("main_menu")

func set_soul_counter():
	var soul_amount = Global.load_player_data().souls
	$SoulCounter/HBoxContainer/Label.text = str(soul_amount)

func swap_selected_character(id):
	var character: PlayableCharacterData = PlayableCharactersPool.characters[id]
	character_name.text = character.display_name
	character_description.text = character.description
	
	set_character_button(id)
	
	Global.current_player = character
	
	update_details(character)
	update_arrow(id)

func set_character_button(id: int):
	var unlocked = PlayableCharactersPool.is_character_unlocked(id)
	
	if unlocked:
		play_button.visible = true
		unlock_button.visible = false
	else:
		play_button.visible = false
		var cost = PlayableCharactersPool.characters[id].unlock_cost
		unlock_button.text = "UNLOCK (" + str(cost) + ")"
		unlock_button.visible = true
		
		var player_data = Global.load_player_data()
		if player_data == null:
			unlock_button.disabled = true
			return
		if player_data.souls < cost:
			unlock_button.disabled = true

func update_details(character: PlayableCharacterData):
	var ability_1 = ability_display.get_node("Ability1")
	var ability_2 = ability_display.get_node("Ability2")
	var movement_ability = ability_display.get_node("MovementAbility")
	var passive = ability_display.get_node("Passive")
	var primary_gun = ability_display.get_node("PrimaryGun")
	var secondary_gun = ability_display.get_node("SecondaryGun")
	
	update_ability(ability_1, character, 0, "Q: ")
	update_ability(ability_2, character, 1, "E: ")
	update_ability(movement_ability, character, 2, "SHIFT: ")
	update_ability(passive, character, 3, "PASSIVE: ")
	update_ability(primary_gun, character, 4, "LEFT CLICK: ")
	update_ability(secondary_gun, character, 5, "RIGHT CLICK: ")

func update_ability(ability, character: PlayableCharacterData, index: int, name_prefix: String):
	var texture_rect_path: String = "TextureRect"
	var name_path: String = "VBoxContainer/Name"
	var description_path: String = "VBoxContainer/Description"
	
	if character.abilities[index].icon != null && ability.get_node_or_null(texture_rect_path) != null:
		ability.get_node(texture_rect_path).texture = character.abilities[index].icon
	ability.get_node(name_path).text = name_prefix + character.abilities[index].display_name
	ability.get_node(description_path).text = character.abilities[index].description

func set_confirm_popup():
	var character_data = PlayableCharactersPool.characters[current_selected_character]
	
	confirm_popup.get_node("Label").text = "Do you want to spend " + str(character_data.unlock_cost) + " souls to unlock [" + character_data.display_name + "]?"

func purchase_character():
	var character = PlayableCharactersPool.characters[current_selected_character]
	var data = Global.load_player_data()
	data.souls -= character.unlock_cost
	data.unlocked_characters[character.display_name] = true
	Global.save_player_data(data)
	set_soul_counter()
	swap_selected_character(current_selected_character)
	
	character_unlocked.emit()
	
	$CharacterUnlockedSound.play()
	
	play_confettis()
	
	congratulations_popup.get_node("Label").text = "Congratulations! You have successfully unlocked [" + character.display_name + "]"
	set_screen(3)

func _on_play_button_pressed() -> void:
	Global.load_scene("game")
	on_button_pressed()

func _on_details_button_pressed() -> void:
	set_screen(1)
	on_button_pressed()


func _on_left_button_pressed() -> void:
	current_selected_character -= 1
	if current_selected_character < 0:
		current_selected_character = PlayableCharactersPool.characters.size() - 1
	
	swap_selected_character(current_selected_character)
	on_button_pressed()


func _on_right_button_pressed() -> void:
	current_selected_character += 1
	if current_selected_character > PlayableCharactersPool.characters.size() - 1:
		current_selected_character = 0
	
	swap_selected_character(current_selected_character)
	on_button_pressed()


func _on_unlock_button_pressed() -> void:
	set_confirm_popup()
	set_screen(2)
	on_button_pressed()



func _on_unlock_confirm_button_pressed() -> void:
	purchase_character()
	on_button_pressed()


func _on_unlock_deny_button_pressed() -> void:
	set_screen(0)
	on_button_pressed()


func _on_close_details_button_pressed() -> void:
	set_screen(0)
	on_button_pressed()

func set_screen(index):
	match index:
		0:
			character_screen.visible = true
			details_screen.visible = false
			confirm_popup.visible = false
			congratulations_popup.visible = false
		1:
			character_screen.visible = false
			details_screen.visible = true
			confirm_popup.visible = false
			congratulations_popup.visible = false
		2:
			character_screen.visible = false
			details_screen.visible = false
			confirm_popup.visible = true
			Global.play_popup_effect(confirm_popup, true)
			congratulations_popup.visible = false
		3:
			character_screen.visible = false
			details_screen.visible = false
			confirm_popup.visible = false
			congratulations_popup.visible = true
			Global.play_popup_effect(congratulations_popup, true)
		
func on_button_pressed():
	$ButtonPressedPlayer.play()


func _on_back_pressed() -> void:
	Global.load_scene("main_menu")

func update_arrow(id):
	var parent = $Characters
	if parent.get_child_count() >= id - 1:
		var sprite = parent.get_child(id)
		$PointerArrow.global_position = sprite.global_position + (Vector2.UP * 40)

func play_confettis():
	confettis.restart()
