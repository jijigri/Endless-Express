class_name StatusEffectsManager
extends Node2D

@export var time_multiplier: float = 1.0

signal effect_applied(effect: String, duration: float)
signal effect_removed(effect: String)

var status_effects = {
	"freeze": preload("res://Scenes/Misc/StatusEffects/freeze_status_effect.tscn"),
	"hack": preload("res://Scenes/Misc/StatusEffects/hack_status_effect.tscn")
}

var current_effects : Array[StatusEffect] = []

func set_status_effect(effect: String, time: float):
	if status_effects.has(effect):
		var scene = status_effects[effect]
		var status = Global.spawn_object(scene, position, 0, self)
		status.initialize(self, owner, effect, time * time_multiplier)
		current_effects.append(status)
		effect_applied.emit(effect, time * time_multiplier)

func remove_effect(effect_name: String, called_from_effect: bool = false):
	var success: bool = false
	for status in current_effects:
		if status.effect_name == effect_name:
			status.disable_effect(true)
			success = true
			current_effects.erase(status)
	
	if success:
		effect_removed.emit(effect_name)

func has_effect(effect_name: String) -> bool:
	for status in current_effects:
		if status.effect_name == effect_name:
			return true
	return false
