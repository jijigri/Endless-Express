@tool
class_name PickupSpawner
extends TileMap

@export var update_pickups: bool = false:
	set(value):
		update_pickups = false
		update_pickups_placed()

@export var pickups_placed: int = 0:
	set(value):
		pickups_placed = value

@onready var super_powerup_spawn_point = $SuperPowerupSpawnPoint

var editor

var super_powerup = preload("res://Scenes/Misc/super_powerup.tscn")

#HEALTH = 0
#ENERGY = 1
var pickups: Array[PackedScene] = [
	preload("res://Scenes/Entities/Pickups/health_pickup.tscn"),
	preload("res://Scenes/Entities/Pickups/energy_pickup.tscn")
	]

var current_number_of_pickups = 0

var can_spawn_super_powerup = true

func _ready() -> void:
	if Engine.is_editor_hint() == false:
		visible = false

func spawn_pickups(arena: Node2D) -> void:
	
	if Engine.is_editor_hint() == true:
		return
	
	current_number_of_pickups = 0
	
	if pickups.size() <= 0:
		return

	for cell in get_used_cells(0):
		var type: int = get_cell_tile_data(0, cell).get_custom_data("type")
		
		if type == -1:
			continue
		
		var instance
		if type < pickups.size():
			instance = Global.spawn_object(pickups[type], to_global(map_to_local(cell)), 0, arena)
		else:
			instance = Global.spawn_object(pickups[0], cell, 0, arena)
		
		instance.initialize(self)
		
		current_number_of_pickups += 1
	
	print_debug(name, ": ", current_number_of_pickups, " pickups")
	
	clear()

func remove_pickup():
	if Engine.is_editor_hint() == true:
		return
	
	current_number_of_pickups -= 1
	
	if can_spawn_super_powerup:
		if current_number_of_pickups <= 0:
			spawn_super_pickup()

func spawn_super_pickup():
	if Engine.is_editor_hint() == true:
		return
	
	can_spawn_super_powerup = false
	Global.spawn_object(super_powerup, super_powerup_spawn_point.global_position)
	HUD.play_sliding_text("SUPER POWERUP APPEARED", 0.8, 0.25)


func update_pickups_placed() -> void:
	if Engine.is_editor_hint() == false:
		return
	
	pickups_placed = get_used_cells(0).size()
	notify_property_list_changed()

