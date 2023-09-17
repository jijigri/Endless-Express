extends ChaserStateMachine

@export var close_movement: EntityMovement

@export var explosion_size: float = 64.0
@export var explosion_damage: float = 80.0
@export var explosion_scene: PackedScene

@onready var health_bar = $ArmoredHealthBar
@onready var audio: AudioStreamPlayer2D = $FlySound

var last_damage_velocity: Vector2

var is_dead: bool = false

var active: bool = true

func _ready() -> void:
	movement_states.append(close_movement)
	var max_time = default_movement.max_time
	var rand = randf_range(-2.0, 2.0)
	default_movement.max_time = max_time + rand
	close_movement.max_time = max_time + rand
	
	super._ready()
	
	audio.volume_db = -20
	var tween = create_tween()
	tween.tween_property(audio, "volume_db", 0.0, 0.8)
	tween.play()

func _process(delta: float) -> void:
	super._process(delta)
	
	if distance_to_player < 64.0:
		if current_state == default_movement:
			set_state(close_movement)
	else:
		if current_state == close_movement:
			set_state(default_movement)
	
	if is_dead:
		if active:
			linear_velocity = (last_damage_velocity.normalized() * 950)
			
			if get_contact_count() > 0:
				explode()

func _on_health_manager_entity_killed() -> void:
	if !is_dead:
		CameraManager.freeze(0.12)
		await get_tree().process_frame
		
		if last_damage_velocity.length() < 10:
			kill()
			return
		#print_debug(last_damage_velocity)
		
		for i in movement_states:
			i.move_speed = 0.0
			i.speed_modifiers.append(0.0)
		
		health_bar.visible = false
		
		attacks[0].auto_monitor = false
		
		var particles = sprite.get_node("NormalParticles")
		particles.amount = 40
		particles.modulate = Color("fabf79")
		
		is_dead = true

func on_damaged(damage_data):
	if !is_dead:
		last_damage_velocity = damage_data.velocity
		super.on_damaged(damage_data)
	else:
		explode()

func explode():
	var instance = Global.spawn_object(explosion_scene, global_position)
	instance.initialize(explosion_size, explosion_damage, 5.0)
	kill()
	active = false

func kill():
	super.kill()

func set_sprite_direction():
	var angle = Helper.angle_between(global_position, global_position + linear_velocity.normalized())
	sprite.rotation_degrees = angle
	
	if sprite.rotation_degrees < -80 || sprite.rotation_degrees > 80:
		sprite.flip_v = true
	else:
		sprite.flip_v = false


func _on_collision_damage_damage_dealt() -> void:
	kill()
