extends Node2D

var challenges

var current_challenge_progress: Dictionary

func _ready() -> void:
	initialize_challenges()

func initialize_challenges():
	challenges = get_children()
	var save_data: PlayerSaveData = Global.load_player_data()
	
	for curr in challenges:
		if save_data.challenges.has(curr.name):
			curr.initialize(self)
			curr.set_data(save_data.challenges[curr.name])
		else:
			curr.initialize(self)
			var challenge_data = curr.get_data()
			save_data.challenges[curr.name] = challenge_data
		
		if curr.achieved == false:
			curr.start_recording_challenge()
	
	Global.save_player_data(save_data)
	current_challenge_progress = save_data.challenges

func progress_challenge(key, goal, progress):
	current_challenge_progress[key].goal = goal
	current_challenge_progress[key].progress = progress

func complete_challenge(key):
	current_challenge_progress[key].achieved = true
