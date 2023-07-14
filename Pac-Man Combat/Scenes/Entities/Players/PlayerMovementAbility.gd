class_name PlayerMovementAbility
extends Node2D

@export var cooldown: float = 1.0
@export var display_icon: Texture2D
@export var provides_iframes: bool = true

@onready var current_cooldown = 0
@onready var player_movement: PlayerMovement = get_parent()
@onready var player_health_manager: PlayerHealthManager = get_parent().get_node("HealthManager")

func _ready() -> void:
	HUD.player_hud.set_movement_ability_icon(display_icon, InputMap.action_get_events("dash")[0].as_text_physical_keycode())

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("dash"):
		use_ability()
	
	if current_cooldown > 0:
		current_cooldown -= delta
	
	HUD.player_hud.update_movement_ability(current_cooldown, cooldown)

func use_ability():
	if current_cooldown > 0.1:
		return

func set_on_cooldown():
	current_cooldown = cooldown
