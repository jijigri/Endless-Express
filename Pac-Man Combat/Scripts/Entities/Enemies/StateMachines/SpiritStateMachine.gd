extends TargetStateMachine

@export var possess_movement: EntityMovement
@export var possess_time: float = 15.0
@export var stun_time: float = 5.0

@onready var ghost_trail = $Sprite/GhostTrail
@onready var possess_timer = $PossessTimer
@onready var stun_player = $StunPlayer
@onready var trail = $Trail

var start_possess_sound = preload("res://Audio/SoundEffects/Enemies/TargetSpirit/SpiritStartPossessSound.wav")
var enter_body_sound = preload("res://Audio/SoundEffects/Enemies/TargetSpirit/SpiritEnterBodySound.wav")
var exit_body_sound = preload("res://Audio/SoundEffects/Enemies/TargetSpirit/SpiritExitBodySound.wav")

var target = null
var last_target_position: Vector2

var stunned: bool = false

func _ready() -> void:
	add_movement_state(possess_movement)
	super._ready()
	trail.default_color = sprite.material.get_shader_parameter("NEW_COLOR2")
	trail.visible = false

func _process(delta: float) -> void:
	if current_state == possess_movement && target != null:
		current_state.target_position = target.global_position
		if global_position.distance_squared_to(target.global_position) < 1000:
			enter_target_body()
	
	if target != null && visible == false:
		global_position = target.global_position


func possess():
	#print_debug("Possessing")
	
	if frozen:
		stop_possession()
		return
	
	get_enemy_to_possess()
	if target != null:
		sprite.play("possess_begin")
		
		var audio_data = AudioData.new(start_possess_sound, global_position)
		audio_data.max_distance = 3400.0
		AudioManager.play_sound(audio_data)
		
		trail.visible = true

func get_enemy_to_possess():
	var possible_targets = get_tree().get_nodes_in_group("Chasers")
	possible_targets.shuffle()
	target = null
	
	for i in possible_targets:
		if !i.status_effects_manager.has_effect("spirit_possess"):
			
			target = i
			return
	
	print_debug("No valid target found")

func enter_target_body():
	current_state.stop()
	current_state = default_movement
	set_processes()
	current_state.start()
	
	ghost_trail.enabled = false
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.play()
	
	var audio_data = AudioData.new(enter_body_sound, global_position)
	audio_data.max_distance = 2000.0
	AudioManager.play_sound(audio_data)
	
	await tween.finished
	
	if target == null:
		stunned = true
		stop_possession()
		return
	
	var manager = target.status_effects_manager
	if manager != null:
		manager.set_status_effect("spirit_possess", possess_time)
		if !target.killed.is_connected(_on_target_killed):
			target.killed.connect(_on_target_killed)
		if !manager.effect_removed.is_connected(_on_target_status_effect_removed):
			manager.effect_removed.connect(_on_target_status_effect_removed)
		visible = false
		hurtbox.set_deferred("monitorable", false)
	else:
		stop_possession()

func _on_target_killed(global_pos):
	stunned = true
	stop_possession()

func _on_target_status_effect_removed(effect):
	if effect == "spirit_possess":
		stop_possession()

func stop_possession():
	scale = Vector2.ONE
	sprite.play("possess_end")
	visible = true
	hurtbox.set_deferred("monitorable", true)
	trail.visible = false
	target = null
	possess_timer.stop()
	
	var audio_data = AudioData.new(exit_body_sound, global_position)
	audio_data.max_distance = 2000.0
	AudioManager.play_sound(audio_data)

func stun_timer():
	stun_player.play()
	await get_tree().create_timer(stun_time).timeout
	sprite.play("default")
	stunned = false
	possess_timer.start()

func _on_sprite_animation_finished() -> void:
	if sprite.animation == "possess_begin":
		if target != null:
			possess_movement.target_position = target.global_position
			
			current_state.stop()
			current_state = possess_movement
			set_processes()
			current_state.start()
			ghost_trail.enabled = true
		else:
			stop_possession()
	
	if sprite.animation == "possess_end":
		if stunned:
			sprite.play("stunned")
			stun_timer()
		else:
			possess_timer.start()
			sprite.play("default")


func _on_status_effects_manager_effect_applied(effect, duration) -> void:
	if effect == "freeze":
		if current_state != possess_movement:
			target = null
			current_state.stop()
			current_state = default_movement
			set_processes()
			current_state.start()
			
			ghost_trail.enabled = false
			hurtbox.set_deferred("monitorable", true)
			trail.visible = false


func _on_possess_timer_timeout() -> void:
	if target == null && current_state != possess_movement && !stunned:
		possess()
