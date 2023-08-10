class_name SplashText
extends Label

enum MODE {DEFAULT, WONDER, SLIDE}

var fade_in: float = 0.5
var fade_out: float = 0.5
var duration: float = 0.5
var mode: MODE

func initialize(_text: String, fade_in: float = 0.1, fade_out: float = 0.1, duration: float = 0.5, mode = MODE.DEFAULT, color: String = "white"):
	text = _text
	self.fade_in = fade_in
	self.fade_out = fade_out
	self.duration = duration
	self.mode = mode
	
	match color:
		"red":
			modulate = Color("e12b2b")
		"yellow":
			modulate = Color("fabf79")
		"orange":
			modulate = Color("e37927")

func _ready() -> void:
	global_position += -size / 2
	
	match mode:
		MODE.DEFAULT:
			play_default()
		MODE.WONDER:
			play_wonder()
		MODE.SLIDE:
			play_slide()

func play_default():
	label_settings.font_size = 1.0
	var tween = create_tween()
	tween.tween_property(self, "label_settings:font_size", 16.0, fade_in).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	await tween.finished
	
	await get_tree().create_timer(duration).timeout
	
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(self, "label_settings:font_size", 14.0, fade_out).set_ease(Tween.EASE_IN)
	
	var end_tween = create_tween()
	end_tween.tween_property(self, "modulate:a", 0, fade_out).set_ease(Tween.EASE_IN)
	end_tween.tween_callback(queue_free)

func play_wonder():
	label_settings.font_size = 1.0
	visible_ratio = 0.0
	
	var tween = create_tween()
	tween.tween_property(self, "label_settings:font_size", 16.0, fade_in).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

	
	var appear_tween = create_tween()
	appear_tween.tween_method(wonder_text, 0.0, 1.0, fade_in)
	
	await tween.finished
	
	await get_tree().create_timer(duration).timeout
	
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(self, "label_settings:font_size", 14.0, fade_out).set_ease(Tween.EASE_IN)
	var end_tween = create_tween()
	end_tween.tween_property(self, "modulate:a", 0, fade_out).set_ease(Tween.EASE_IN)
	end_tween.tween_callback(queue_free)

func wonder_text(value):
	visible_ratio = value

func play_slide():
	label_settings.font_size = 1.0
	
	position = position + Vector2(0, 16)
	
	var pos_tween = create_tween()
	pos_tween.tween_property(self, "position", position + Vector2(0, -16), fade_out).set_ease(Tween.EASE_IN)
	
	var tween = create_tween()
	tween.tween_property(self, "label_settings:font_size", 16.0, fade_in).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	await tween.finished
	
	await get_tree().create_timer(duration).timeout
	
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(self, "label_settings:font_size", 14.0, fade_out).set_ease(Tween.EASE_IN)
	
	var pos_out_tween = create_tween()
	pos_out_tween.tween_property(self, "position", position + Vector2(0, -16), fade_out).set_ease(Tween.EASE_IN)
	
	var end_tween = create_tween()
	end_tween.tween_property(self, "modulate:a", 0, fade_out).set_ease(Tween.EASE_IN)
	end_tween.tween_callback(queue_free)
