@tool
extends TextEdit
@export var line_limit: int = 4
var current_text = ''
var caret_line = 0
var caret_column = 0

func _on_text_changed() -> void:
	
	if is_caret_visible() == false:
			text = current_text
			set_caret_line(caret_line)
			set_caret_column(caret_column)
	
	for i in get_line_count():
		if i >= line_limit:
			text = current_text
			set_caret_line(caret_line)
			set_caret_column(caret_column)
	
	current_text = text
	caret_line = get_caret_line()
	caret_column = get_caret_column()
