class_name SpawnIndicatorType
extends Node

enum TYPE {DANGER, PASSIVE, SIREN_SPAWN}
var scenes: Array[PackedScene] = [preload("res://Scenes/Effects/danger_spawn_indicator.tscn")]

func scene_from_type(type: TYPE) -> PackedScene:
	#FOR NOW, ONLY RETURNS THE ONE EFFECT IN LIST
	#TODO: MAKE IT RETURN BASED ON THE TYPE
	if scenes.size() > type:
		return scenes[type]
	else:
		return scenes[0]
