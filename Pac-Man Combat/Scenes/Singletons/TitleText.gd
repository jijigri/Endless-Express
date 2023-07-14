class_name TitleText
extends Node2D

@onready var label: Label = $Label
@onready var timer: Timer = $Timer

func set_title(text: String, time: float):
	label.text = text
	timer.start(time)


func _on_timer_timeout() -> void:
	queue_free()
