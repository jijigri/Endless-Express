class_name MenuAbilitySlot
extends Panel

@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %Name
@onready var description_label: Label = %Description

func initialize(data: AbilityData) -> void:
	icon.texture = data.icon
	name_label.text = data.display_name
	description_label.text = data.description
