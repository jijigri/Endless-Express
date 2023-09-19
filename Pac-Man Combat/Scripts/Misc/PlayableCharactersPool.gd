extends Node2D

@export var characters: Array[PlayableCharacterData] = []

func _ready() -> void:
	initialize_save_data()

func initialize_save_data():
	var player_data: PlayerSaveData = Global.load_player_data()
	
	for i in characters:
		if !player_data.unlocked_characters.has(i.display_name):
			print_debug("Character ", i.display_name, " not in file")
			if i.unlock_cost <= 0:
				player_data.unlocked_characters[i.display_name] = true
				print_debug("Adding ", i.display_name, " to data")
			else:
				player_data.unlocked_characters[i.display_name] = false
	Global.save_player_data(player_data)

func is_character_unlocked(id) -> bool:
	var player_data: PlayerSaveData = Global.load_player_data()
	if player_data == null:
		initialize_save_data()
		return false
	
	var name = characters[id].display_name
	
	if player_data.unlocked_characters.has(name):
		return player_data.unlocked_characters[name]
	
	return false
