class_name SoulReward
extends Reward

@export var value: int = 500

func update_text():
	text = str(value) + " SOULS"

func get_reward(source: Node):
	var data = Global.load_player_data()
	data.souls += value
	Global.save_player_data(data)
	source.get_tree().call_group("TrainStation", "set_soul_counter")
