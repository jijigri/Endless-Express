extends TabContainer

var challenges

var challenge_panel = preload("res://Scenes/UI/challenge_panel.tscn")
var challenge_container = preload("res://Scenes/UI/challenge_container.tscn")

func _ready() -> void:
	challenges = ChallengeManager.challenges
	
	var categories = []
	var challenge_by_category = {}
	
	for item in challenges:
		var char_name = item.character_name
		if !categories.has(char_name.to_upper()):
			if char_name == "":
				char_name = "GENERAL"
				if  !categories.has("GENERAL"):
					categories.append(char_name.to_upper())
			else:
				categories.append(char_name.to_upper())
			
		if challenge_by_category.has(char_name.to_upper()):
			challenge_by_category[char_name.to_upper()].append(item)
		else:
			challenge_by_category[char_name.to_upper()] = [item]
	
	print_debug(categories)
	for c in categories:
		var node = challenge_panel.instantiate()
		node.name = c
		call_deferred("add_child", node)
		
		var category_challenges = challenge_by_category[c]
		for challenge in category_challenges:
			var container = challenge_container.instantiate()
			node.get_node("ScrollContainer/List").call_deferred("add_child", container)
			container.initialize(challenge)
