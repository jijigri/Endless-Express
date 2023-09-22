extends PlayerMovementAbility

@export var dash_speed: float = 1750
@export var dash_distance: float = 64.0
@export var charged_dash_distance: float = 220.0
@export var damage: float = 40
@export var armor_break_time: float = 3.0

@export var passive: NinjaBoyPassiveAbility
@export var player_gun: PlayerGun
@export var player_animations: PlayerAnimator

@onready var shape_cast: Area2D = $Area2D
@onready var trail = $GhostTrail
var sprite_anim

var direction: Vector2 = Vector2.UP
var dash_dir: Vector2

var last_position: Vector2
var initial_pos: Vector2
var dash_end_position: Vector2

var detected_enemy_hurtboxes = []

var line_width = 0.0

var speed

var can_reset: bool = true

var normal_sound = preload("res://Audio/SoundEffects/Player/NinjaBoy/NormalDashSound.wav")
var charged_sound = preload("res://Audio/SoundEffects/Player/NinjaBoy/ChargedDashSound.wav")

func _ready() -> void:
	super._ready()
	player_movement.landed.connect(_on_player_land)
	player_movement.wall_landed.connect(_on_player_wall_land)
	player_movement.moved.connect(_on_player_moved)
	
	GameEvents.player_killed.connect(_on_player_killed)
	
	trail.enabled = false
	await get_tree().process_frame
	var player_sprite = player_movement.sprite
	sprite_anim = player_sprite.animation
	var curr_frame = player_sprite.frame
	trail.texture = player_movement.sprite.sprite_frames.get_frame_texture(sprite_anim, curr_frame)
	#shape_cast.enabled = false

func _process(delta: float) -> void:
	direction = get_direction()
	
	update_trail()
	
	if Input.is_action_just_pressed("dash"):
		use_ability()
	
	if current_cooldown > 0:
		current_cooldown -= delta
		
		if !player_movement.is_on_floor() && !player_movement.is_wall_sliding:
			if current_cooldown < 0.1:
				current_cooldown = 0.1
		else:
			if current_cooldown <= 0.1:
				current_cooldown = 0
	
	HUD.player_hud.update_movement_ability(current_cooldown, cooldown)
	
	queue_redraw()
	
	"""
	if Input.is_action_just_pressed("ability_3"):
		Engine.max_fps = 20
	elif Input.is_action_just_pressed("ability_4"):
		Engine.max_fps = 144
	"""

func _on_player_moved(velocity):
	
	if player_movement.is_dashing:
		speed = global_position.distance_to(last_position)
		#print_debug(speed)
		if speed <= 0.05:
			stop_velocity()
			stop_dashing()
	last_position = global_position

func _physics_process(delta: float) -> void:
	if player_movement.is_dashing:
		if player_movement.is_on_ceiling():
			stop_velocity()
			stop_dashing()
	
func get_direction() -> Vector2:
	var dir = direction
	
	var dir_x: int = player_movement.direction.x
	
	if player_movement.is_wall_sliding:
		if player_movement.last_wall_direction == -1 && dir_x == -1:
			dir_x = -dir_x
		if player_movement.last_wall_direction == 1 && dir_x == 1:
			dir_x = -dir_x
	
	var dir_y: int = 0
	if Input.is_action_pressed("move_up"):
		dir_y = -1
	elif Input.is_action_pressed("move_down") && !player_movement.is_on_floor():
		dir_y = 1
	
	dir = Vector2(dir_x, dir_y)
	if dir != Vector2.ZERO:
		return dir.normalized()
	else:
		return direction.normalized()

func use_ability():
	super.use_ability()
	if current_cooldown > 0.0:
		return
	if player_movement.is_dashing:
		return
	
	dash()

func dash():
	
	GameEvents.movement_ability_used.emit(self)
	
	var charged = is_charged()
	dash_dir = direction
	
	dash_effect(dash_dir, charged)
	if player_health_manager != null:
		player_health_manager.is_rolling = true
	
	#shape_cast.enabled = true
	detected_enemy_hurtboxes.clear()
	
	var distance = dash_distance if charged == false else charged_dash_distance
	
	player_movement.is_dashing = true
	initial_pos = global_position
	var d: float = 0.0
	while (d < distance):
		if !player_movement.is_dashing:
			return
		
		player_movement.velocity = dash_dir * dash_speed

		d = initial_pos.distance_to(global_position)
		
		if charged:
			get_collisions()
		
		await get_tree().process_frame
	
	#shape_cast.enabled = false
	
	stop_velocity()
	stop_dashing()

func is_charged() -> bool:
	if passive.current_charges >= passive.max_amount_of_charges:
		passive.reset_charges()
		return true
	else:
		return false
	

func dash_effect(direction: Vector2, charged: bool) -> void:
	trail.enabled = true
	disable_gun()
	player_animations.is_dash_charged = charged
	player_animations.is_dashing = true
	var audio_data: AudioData
	if charged:
		line_width = 4.0
		CameraManager.freeze(0.125, 0.1)
		CameraManager.shake(3.5, 0.14, false)
		CameraManager.zoom_in(-0.12, 0.14)
		trail.ghost_lifetime = 0.5
		var instance = Global.spawn_object(ScenesPool.shockwave, global_position)
		instance.initialize(0.3, 10.0, 0.4, 0.18)
		audio_data = AudioData.new(charged_sound, global_position)
	
	else:
		line_width = 0.0
		CameraManager.slide(direction * 10.0, 0.1, 0.25)
		trail.ghost_lifetime = 0.25
		audio_data = AudioData.new(normal_sound, global_position)
	
	AudioManager.play_sound(audio_data)

func get_collisions():
	#shape_cast.force_update_transform()
	#shape_cast.force_shapecast_update()
	
	for col in shape_cast.get_overlapping_areas():
		var collision = col 
		if detected_enemy_hurtboxes.has(collision) == false:
			if collision.is_in_group("Hurtbox"):
				if collision.has_method("receive_hit"):
					var damage_data = DamageData.new(damage, global_position, direction * 500, armor_break_time)
					damage_data.source = self
					collision.receive_hit(damage_data)
					detected_enemy_hurtboxes.append(collision)

func stop_dashing():
	if player_movement.is_dashing == false:
		return
	
	player_movement.is_dashing = false
	set_on_cooldown()
	
	dash_end_position = global_position
	
	trail.enabled = false
	enable_gun()
	player_animations.is_dashing = false
	
	var tween = create_tween()
	tween.tween_property(self, "line_width", 0.0, 0.2)
	
	await get_tree().create_timer(0.1).timeout
	
	if player_health_manager != null:
		player_health_manager.is_rolling = false

func _on_player_land() -> void:
	if player_movement.is_dashing == false:
		return
	
	stop_dashing()

func _on_player_wall_land() -> void:
	if player_movement.is_dashing == false:
		return
	
	if player_movement.is_jump_bufferd() == false:
		stop_velocity()
	stop_dashing()

func stop_velocity():
	if dash_dir.x != 0:
		player_movement.velocity.x = player_movement.velocity.x / 6
	if dash_dir.y != 0:
		player_movement.velocity.y = player_movement.velocity.y / 4

func update_trail(): 
	var curr_frame = player_movement.sprite.frame
	if sprite_anim != null:
		trail.texture = player_movement.sprite.sprite_frames.get_frame_texture(sprite_anim, curr_frame)
		trail.scale.x = -1 if player_movement.sprite.flip_h == true else 1

func disable_gun():
	player_gun.active = false
	player_gun.visible = false

func enable_gun():
	player_gun.active = true
	player_gun.visible = true

func _on_player_killed():
	trail.enabled = false

func _draw():
	var pos = position
	if !player_movement.is_dashing:
		pos = dash_end_position - global_position
	
	if line_width > 0:
		draw_line(initial_pos - global_position, pos, Color.WHITE, line_width, false)
