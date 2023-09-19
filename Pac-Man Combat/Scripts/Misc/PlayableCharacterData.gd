class_name PlayableCharacterData
extends Resource

@export var scene: PackedScene

@export_group("Display Data")
@export var display_name: String = "Name"
@export_multiline var description: String = "Description"
@export var abilities: Array[AbilityData]
@export var portrait: Texture2D
@export var unlock_cost: int = 0

var is_unlocked: bool = false
