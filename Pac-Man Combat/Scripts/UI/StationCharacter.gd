extends AnimatedSprite2D

var id = 0

func _ready() -> void:
	owner.character_unlocked.connect(_on_character_unlocked)
	
	for i in get_parent().get_child_count():
		if get_parent().get_child(i) == self:
			id = i
	
	update_shader()

func update_shader():
	var char = PlayableCharactersPool.characters[id]
	if Global.load_player_data().unlocked_characters[char.display_name] == false:
		material.set_shader_parameter("strength", 1.0)
	else:
		material.set_shader_parameter("strength", 0.0)

func _on_character_unlocked():
	update_shader()
