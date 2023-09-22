extends Challenge

var failed: bool = false

func start_recording_challenge():
	super.start_recording_event()
	
	failed = false
	if !GameEvents.score_updated.is_connected(_on_score_updated):
		GameEvents.score_updated.connect(_on_score_updated)
	if !GameEvents.movement_ability_used.is_connected(_on_movement_ability_used):
		GameEvents.movement_ability_used.connect(_on_movement_ability_used)

func _on_score_updated(score: int):
	if failed:
		return
	
	if character_name == "" || character_name == Global.current_player.display_name:
		if score > progress:
			progress = score
			progress_challenge()
			if progress >= goal:
				complete_challenge()

func _on_movement_ability_used(ability):
	failed = true
