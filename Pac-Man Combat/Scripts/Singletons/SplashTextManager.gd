extends Node

var waving_text = preload("res://Scenes/UI/waving_text.tscn")

var instance = null

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ability_4"):
		start_test()

func start_test(time: float = 1.0):

	instance = Global.spawn_object(waving_text, get_tree().get_first_node_in_group("Player").global_position - (Vector2.RIGHT * 600))
	instance.text = "[center][waving amp=16 speed=5]This is a test"
	
	instance.custom_effects[0] = instance.custom_effects[0].duplicate(true)
	var text: RichTextLabel
	instance.custom_effects[0].size = instance.get_total_character_count()
	print_debug(instance.custom_effects[0].size)
	var text_effect = instance.custom_effects[0]
	instance.custom_effects[0].time = randf_range(0.0, 1.0)
	var tween = create_tween()
	tween.tween_method(tween_text_effect, 0.0, 1.0, time)
	tween.play()

func tween_text_effect(value):
	instance.custom_effects[0].time = value
