class_name StatusEffectsManager
extends Node2D

@export var buff_multiplier: float = 1.0
@export var nerf_multiplier: float = 1.0

signal effect_applied(effect: String, duration: float)
signal effect_removed(effect: String)

var status_effects = {
	"freeze": preload("res://Scenes/Misc/StatusEffects/freeze_status_effect.tscn"),
	"hack": preload("res://Scenes/Misc/StatusEffects/hack_status_effect.tscn"),
	"stagger": preload("res://Scenes/Misc/StatusEffects/stagger_status_effect.tscn"),
	"slow": preload('res://Scenes/Misc/StatusEffects/slow_status_effect.tscn'),
	"super_shield": preload("res://Scenes/Misc/StatusEffects/super_shield_status_effect.tscn"),
	"shield": preload("res://Scenes/Misc/StatusEffects/shield_status_effect.tscn"),
	"poison": preload("res://Scenes/Misc/StatusEffects/poison_status_effect.tscn"),
	"spirit_possess": preload("res://Scenes/Misc/StatusEffects/spirit_possess_status_effect.tscn")
}

var current_effects : Array[StatusEffect] = []

func set_status_effect(effect: String, time: float):
	if status_effects.has(effect):
		var scene = status_effects[effect]
		var status = Global.spawn_object(scene, position, 0, self)
		
		var modifier = buff_multiplier if status.type == StatusEffect.TYPE.BUFF else nerf_multiplier

		status.initialize(self, owner, effect, time * modifier)
		current_effects.append(status)
		effect_applied.emit(effect, time * modifier)
		
		return status
	
	return null

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

func number_of_effects(effect_name: String = "") -> int:
	if effect_name == "":
		return current_effects.size()
	else:
		var amount: int = 0
		for status in current_effects:
			if status.effect_name == effect_name:
				amount += 1
		return amount
