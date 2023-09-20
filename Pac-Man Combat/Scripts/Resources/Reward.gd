class_name Reward
extends Resource

var text: String = "REWARD":
	get:
		update_text()
		return text

func update_text():
	pass

func get_reward(source):
	pass
