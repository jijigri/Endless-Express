class_name EnergyManager
extends Node2D

@export var max_energy: float = 120

var current_energy = 0

signal energy_updated(current_energy: float, max_energy: float, gain: float)

func add_energy(value: float):
	current_energy += value
	if current_energy > max_energy:
		current_energy = max_energy
	elif current_energy < 0:
		current_energy = 0
		
	energy_updated.emit(current_energy, max_energy, value)

func remove_energy(value: float):
	current_energy -= value
	if current_energy > max_energy:
		current_energy = max_energy
	elif current_energy < 0:
		current_energy = 0
	
	energy_updated.emit(current_energy, max_energy, -value)
