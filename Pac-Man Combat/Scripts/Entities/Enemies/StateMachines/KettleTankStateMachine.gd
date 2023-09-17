class_name KettleTank
extends ChaserStateMachine

@export var time_between_shields: float = 5.0

@onready var shard_scene = preload("res://Scenes/Misc/kettle_shard.tscn")
@onready var shield_support_timer: Timer = $ShieldSupportTimer

var shield_support_start_sound = preload("res://Audio/SoundEffects/Enemies/KettleTank/KettleTankShieldSupportStart.wav")
var shield_support_end_sound = preload("res://Audio/SoundEffects/Enemies/KettleTank/KettleTankShieldSupportEnd.wav")
var angry_sound = preload("res://Audio/SoundEffects/Enemies/KettleTank/KettleTankAngrySound.wav")

var shield
var current_weapon: int = 0

var shard_amount: int = 3
var current_number_of_shards: int = 0

var current_shards = []

var amount_of_enemies_to_shield: int = 1

func _ready() -> void:
	set_shield()
	switch_weapon(0)
	
	super._ready()


func set_shield() -> void:
	shield = status_effects_manager.set_status_effect("super_shield", 9999.0)
	
	current_number_of_shards = 0
	
	spawn_shards()

func _process(delta: float) -> void:
	super._process(delta)
	
	if health_manager.is_armored:
		if distance_to_player > attacks[0].distance_from_player_to_attack * 2:
			if current_weapon == 0:
				switch_weapon(1)
		else:
			if current_weapon == 1:
				switch_weapon(0)
	
	queue_redraw()

func switch_weapon(weapon: int):
	if attacks.size() < 2:
		return
	
	for i in attacks:
		i.active = false
		i.visible = false
	
	attacks[weapon].active = true
	attacks[weapon].visible = true
	
	current_weapon = weapon

func spawn_shards():
		
	await get_tree().process_frame
	await get_tree().process_frame
	
	var arena_manager: ArenaManager = get_tree().get_first_node_in_group("ArenaManager")
	var amount: int = shard_amount
	current_number_of_shards += amount
	for i in amount:
		var rand_pos: Vector2 = arena_manager.get_random_position_on_navmesh()
		var instance = Global.spawn_object(shard_scene, rand_pos)
		instance.shard_destroyed.connect(_on_shard_destroyed)
		current_shards.append(instance)

func _on_shard_destroyed(shard):
	current_shards.erase(shard)
	
	if current_shards.size() <= 0:
		break_shield()
		current_shards.clear()
	else:
		var pitch: float = 0.0
		for i in current_shards:
			pitch += 0.15
			i.pitch += pitch

func break_shield():
	status_effects_manager.remove_effect("super_shield")
	health_manager.break_armor(6.0)
	shield_support_timer.stop()
	
	for i in attacks:
		i.locks += 1
		i.visible = false
	
	var audio_data = AudioData.new(angry_sound, global_position)
	audio_data.max_distance = 2200.0
	AudioManager.play_sound(audio_data)

func _on_health_manager_armor_repaired() -> void:
	super._on_health_manager_armor_repaired()
	set_shield()
	
	for i in attacks:
		i.locks -= 1
		i.visible = true
	
	amount_of_enemies_to_shield = 1
	shield_support_timer.start()

func shield_other_enemy() -> bool:
	var target = select_target()
	if target != null:
		if target.status_effects_manager != null:
			target.status_effects_manager.set_status_effect("shield", 30.0)
			return true
	else:
		sprite.play("default")
	
	return false

func select_target():
	var possible_targets = get_tree().get_nodes_in_group("Chasers")
	possible_targets.shuffle()
	var target = null
	
	for i in possible_targets:
		if !i.status_effects_manager.has_effect("shield") && !i is KettleTank:	
			target = i
	
	return target

func _on_health_manager_damage_tanked(damage_data) -> void:
	if shield != null:
		var tween = create_tween()
		tween.tween_property(shield, "scale", Vector2.ONE * 1.1, 0.05)
		tween.tween_property(shield, "scale", Vector2.ONE, 0.05)
		tween.play()

func _draw() -> void:
	for i in current_shards:
		if i != null:
			#display debug line here
			draw_line(Vector2(), i.global_position - global_position, Color("e37927"), 2.0)


func _on_shield_support_timer_timeout() -> void:
	if !frozen && health_manager.is_armored:
		
		for i in movement_states:
			i.speed_modifiers.append(0.1)
		
		sprite.play("shield_support")


func _on_sprite_animation_finished() -> void:
	if sprite.animation == "shield_support":
		sprite.play("default")


func _on_sprite_frame_changed() -> void:
	if sprite == null:
		return
	
	if sprite.animation == "shield_support" && sprite.frame == 9:
		if !frozen && health_manager.is_armored:
			var success: bool = false
			for i in amount_of_enemies_to_shield:
				if shield_other_enemy():
					success = true
			
			if success:
				var audio_data = AudioData.new(shield_support_end_sound, global_position)
				audio_data.max_distance = 2200.0
				AudioManager.play_sound(audio_data)
		else:
			sprite.play("default")


func _on_status_effects_manager_effect_applied(effect, duration) -> void:
	if effect == "freeze":
		sprite.play("default")


func _on_sprite_animation_changed() -> void:
	if sprite == null:
		return
	
	if sprite.animation == "default":
		for i in movement_states:
			i.speed_modifiers.erase(0.1)
	elif sprite.animation == "shield_support":
		var audio_data = AudioData.new(shield_support_start_sound, global_position)
		audio_data.max_distance = 2200.0
		AudioManager.play_sound(audio_data)
