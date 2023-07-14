extends Explosion

@export var freeze_time = 3.5

func on_hit(hit):
	super.on_hit(hit)
	if hit.status_effects_manager != null:
		hit.status_effects_manager.set_status_effect("freeze", freeze_time)
