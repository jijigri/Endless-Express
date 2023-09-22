extends Challenge

var failed: bool = false

func start_recording_challenge():
	super.start_recording_event()
	
	failed = false
	if !GameEvents.score_updated.is_connected(_on_score_updated):
		GameEvents.score_updated.connect(_on_score_updated)
	if !GameEvents.enemy_killed.is_connected(_on_enemy_killed):
		GameEvents.enemy_killed.connect(_on_enemy_killed)

func _on_score_updated(score: int):
	if failed:
		return
	
	if character_name == "" || character_name == Global.current_player.display_name:
		if score > progress:
			progress = score
			progress_challenge()
			if progress >= goal:
				complete_challenge()

func _on_enemy_killed(enemy):
	if enemy.is_in_group("Targets"):
		failed = true
