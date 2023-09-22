extends Challenge

func start_recording_challenge():
	super.start_recording_event()
	
	if !GameEvents.score_updated.is_connected(_on_score_updated):
		GameEvents.score_updated.connect(_on_score_updated)

func _on_score_updated(score: int):
	if character_name == "" || character_name == Global.current_player.display_name:
		if score > progress:
			progress = score
			progress_challenge()
			if progress >= goal:
				complete_challenge()
