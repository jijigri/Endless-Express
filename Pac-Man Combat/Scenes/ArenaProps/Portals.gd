@tool
extends Node

@export var identifier: int = 0 :
	set(value):
		identifier = value

@onready var portal_a: Portal = $PortalA
@onready var portal_b: Portal = $PortalB

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if identifier > 4:
			identifier = 4
		
		$PortalA.get_node("IdentifierIcon").texture.region.position.x = 8 * identifier
		$PortalB.get_node("IdentifierIcon").texture.region.position.x = 8 * identifier
