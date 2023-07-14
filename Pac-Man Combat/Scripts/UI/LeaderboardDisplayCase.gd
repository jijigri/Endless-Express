extends HSplitContainer

@onready var number_label = $Number
@onready var name_label = $HSplitContainer/Name
@onready var score_label = $HSplitContainer/Score

func set_display_case(index: int, display_name: String, score: String):
	number_label.text = str(index) + "."
	name_label.text = display_name
	score_label.text = score
	
