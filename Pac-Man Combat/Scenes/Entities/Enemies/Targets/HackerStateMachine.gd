extends TargetStateMachine

@export var distance_from_target_to_hack = 64.0
@export var time_to_hack = 2.0
@export var bored_movement: EntityMovement

@onready var hover_audio = $HoverAudio
@onready var hover_particles = $Sprite/Particles

var target

var hacked_targets = []
var is_hacking: bool = false

var can_hack: bool = true

func _ready() -> void:
	add_movement_state(bored_movement)

	super._ready()
	update_target_position()
	start_moving()

func _process(delta: float) -> void:
	set_direction()

func update_target_position():
	await get_tree().create_timer(randf_range(0, 0.5)).timeout
	while(true):
		if target != null:
			if !is_hacking && can_hack:
				if global_position.distance_to(target.global_position) < distance_from_target_to_hack:
					start_hacking()
			
			if target != null:
				current_state.target_position = target.global_position
				current_state.update_path()
		else:
			select_target()
		
		await get_tree().create_timer(0.25).timeout

func start_moving():
	await get_tree().process_frame
	await get_tree().process_frame
	select_target()

func select_target() -> void:
	var possible_targets = get_tree().get_nodes_in_group("ResourceBubbles")
	possible_targets.shuffle()
	target = null
	
	for i in possible_targets:
		if !i.status_effects_manager.has_effect("hack"):
			
			if current_state == bored_movement:
				current_state.stop()
				current_state = default_movement
				set_processes()
				current_state.start()
			
			target = i
			return
	
	#NO VALID TARGET FOUND, ENTERING BORED MOVEMENT
	current_state.stop()
	current_state = bored_movement
	set_processes()
	current_state.start()

func start_hacking():
	is_hacking = true
	
	sprite.play("hacking")
	hover_particles.emitting = false
	hover_audio.pitch_scale = 1.4
	
	await get_tree().create_timer(time_to_hack).timeout
	
	if is_hacking:
		if can_hack:
			hack_target()
			select_target()
		stop_hacking()

func stop_hacking():
	is_hacking = false
	sprite.play("default")
	hover_particles.emitting = true
	hover_audio.pitch_scale = 1.0

func hack_target():
	if target != null:
		target.status_effects_manager.set_status_effect("hack", 999.0)
		hacked_targets.append(target)

func on_damaged(damage_data):
	super.on_damaged(damage_data)
	stop_hacking()

func kill() -> void:
	for t in hacked_targets:
		if t != null:
			t.status_effects_manager.remove_effect("hack")
	
	super.kill()

func set_direction():
	if linear_velocity.x > 0:
		sprite.flip_h = true
	elif linear_velocity.x < 0:
		sprite.flip_h = false


func _on_sprite_frame_changed() -> void:
	if sprite.animation == "hacking":
		if sprite.frame == 2:
			var audio_data = AudioData.new(preload("res://Audio/SoundEffects/Enemies/TargetHacker/HackerHackSound.wav"), global_position)
			audio_data.max_distance = 1200
			audio_data.pitch = randf_range(0.85, 1.15)
			AudioManager.play_sound(audio_data)


func _on_status_effects_manager_effect_applied(effect, duration) -> void:
	if effect == "freeze":
		can_hack = false


func _on_status_effects_manager_effect_removed(effect) -> void:
	if effect == "freeze":
		if !status_effects_manager.has_effect("freeze"):
			can_hack = true
