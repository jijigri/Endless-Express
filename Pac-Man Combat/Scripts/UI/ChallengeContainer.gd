extends HBoxContainer

var challenge: Challenge
var claimed_sound = preload("res://Audio/SoundEffects/UI/ChallengeClaimedSound.wav")

func initialize(challenge: Challenge):
	self.challenge = challenge
	%Condition.text = challenge.description
	%Progress.max_value = challenge.goal
	%Progress.value = challenge.progress if !challenge.claimed && !challenge.achieved else challenge.goal
	%Reward.text = challenge.reward.text if !challenge.claimed else "CLAIMED"
	%Reward.disabled = !challenge.achieved || challenge.claimed


func _on_reward_pressed() -> void:
	challenge.reward.get_reward(self)
	challenge.claimed = true
	%Reward.disabled = true
	%Reward.text = "CLAIMED"
	
	var audio_data = AudioData.new(claimed_sound)
	AudioManager.play_global(audio_data)
	
	var data = Global.load_player_data()
	if data.challenges[challenge.name] != null:
		data.challenges[challenge.name].claimed = true
		print_debug("EVERYTHING WORKS")
		Global.save_player_data(data)
	else:
		print_debug("NOT EVERYTHING WORKS")
	
	get_tree().get_first_node_in_group("TrainStation").play_confettis()
