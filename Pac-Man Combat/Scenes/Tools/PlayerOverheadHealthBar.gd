extends OverheadHealthBar

@export var normal_color: Color
@export var danger_color: Color

@export var gain_color: Color
@export var loss_color: Color

func increase_value(value: float) -> void:
	back_bar.tint_progress = gain_color
	
	if health_manager.is_in_danger:
		tint = danger_color
		tint_progress = danger_color
	else:
		tint = normal_color
		tint_progress = normal_color
	
	super.increase_value(value)

func decrease_value(value: float) -> void:
	back_bar.tint_progress = loss_color
	
	if health_manager.is_in_danger:
		tint = danger_color
		tint_progress = danger_color
	else:
		tint = normal_color
		tint_progress = normal_color
	
	super.decrease_value(value)
