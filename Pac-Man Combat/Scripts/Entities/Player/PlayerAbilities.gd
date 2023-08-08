class_name PlayerAbilities
extends Node2D

@export var energy_manager: EnergyManager

var global_cooldown_time = 0.25
var current_cooldown = 0.0

func _ready() -> void:
	for i in get_child_count():
		var string = "ability_" + str(i + 1)
		HUD.player_hud.set_ability_icon(i, get_child(i).display_icon, InputMap.action_get_events(string)[0].as_text_physical_keycode())

func _process(delta: float) -> void:
	
	#MAKE IT ON HOLD BUT NEED TO RELEASE BEFORE THROWING ANOTHER ONE
	if Input.is_action_just_pressed("ability_1"):
		if get_child_count() >= 1:
			use_ability(get_child(0))
	elif Input.is_action_just_pressed("ability_2"):
		if get_child_count() >= 2:
			use_ability(get_child(1))
	elif Input.is_action_just_pressed("ability_3"):
		if get_child_count() >= 3:
			use_ability(get_child(2))
			#print_debug("I don't have it yet")
	
	if current_cooldown > 0:
		current_cooldown -= delta
	
	for i in get_child_count():
		var current_ability = get_child(i)
		HUD.player_hud.update_ability(i, energy_manager.current_energy, current_ability.energy_cost)

func use_ability(ability: AbilityBase):
	if current_cooldown <= 0:
		if energy_manager.current_energy >= ability.energy_cost:
			ability.use_ability(self)
			energy_manager.remove_energy(ability.energy_cost)
			current_cooldown = global_cooldown_time
		else:
			CustomCursor.display_ability_cost(energy_manager.current_energy, ability.energy_cost)
