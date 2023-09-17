class_name NinjaBoyPassiveAbility
extends Node2D

@export var max_amount_of_charges: int = 3

@onready var rect: NinePatchRect = $Charges

var current_charges: int = 0

var full_sound = preload("res://Audio/SoundEffects/Player/NinjaBoy/ChargesFullSound.wav")

func _ready() -> void:
	GameEvents.enemy_killed.connect(_on_enemy_killed)
	GameEvents.arena_cleared.connect(_on_arena_clear)
	
	update_charges()

func _on_enemy_killed(enemy):
	#if enemy.is_in_group("Targets"):
		add_charges(1)

func add_charges(amount = 1):
	if current_charges < max_amount_of_charges && current_charges + amount >= max_amount_of_charges:
		var audio_data = AudioData.new(full_sound, global_position)
		AudioManager.play_sound(audio_data)
	
	current_charges = clamp(current_charges + amount, 0, max_amount_of_charges)
	update_charges()

func remove_charges(amount):
	current_charges = clamp(current_charges - amount, 0, max_amount_of_charges)
	update_charges()

func reset_charges():
	current_charges = 0
	update_charges()

func update_charges():
	if current_charges <= 0:
		rect.visible = false
		return
	else:
		rect.visible = true
	
	rect.size.x = 3 * current_charges
	
	if current_charges >= max_amount_of_charges:
		rect.modulate = Color("fabf79")
		rect.region_rect.position.x = 3
	else:
		rect.modulate = Color.WHITE
		rect.region_rect.position.x = 0

func _on_arena_clear(arena):
	await get_tree().process_frame
	await get_tree().process_frame
	reset_charges()
