extends PlayerMovementAbility

@export var roll_speed: float = 5.0
@export var roll_invulnerability_time: float = 0.5
@export var air_roll_velocity: Vector2 = Vector2.ZERO
@export var player_animations: PlayerAnimator
@export var roll_animation_time: float = 0.5
@export var player_gun: PlayerGun

var is_rolling: bool = false
var is_diving: bool = false
var can_dive: bool = true

var face_direction: int = 1

func _ready() -> void:
	super._ready()
	player_movement.jumped.connect(on_jump)
	player_movement.landed.connect(on_land)

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("dash"):
		if player_movement.is_on_floor():
			if current_cooldown <= 0.1:
				roll()
		else:
			dive()
	
	if is_diving && player_movement.is_wall_sliding:
		dive_end()
	
	if current_cooldown > 0:
		current_cooldown -= delta
	
	if player_movement.sprite.flip_h:
		face_direction = -1
	else:
		face_direction = 1
	
	HUD.player_hud.update_movement_ability(current_cooldown, cooldown)
	#player_movement.lock_horizontal_movement = is_rolling
	#player_movement.lock_wall_slide = is_rolling


func dive():
	if can_dive:
		var input_direction: float = (
			face_direction if (
					player_movement.velocity.x == 0)
				else (
					sign(player_movement.velocity.x)
					)
			)
		player_movement.velocity = Vector2(
			player_movement.velocity.x + (air_roll_velocity.x * input_direction),
			air_roll_velocity.y
			)
		player_movement.isJumping = false
		is_diving = true

		can_dive = false
		
		player_animations.dive(input_direction)
		
		disable_gun()
		
		GameEvents.movement_ability_used.emit(self)

func roll():
	#roll
	var input_direction: float = (
			face_direction if (
					player_movement.velocity.x == 0)
				else (
					sign(player_movement.velocity.x)
					)
			)
	
	player_movement.velocity = Vector2(roll_speed * input_direction, 0)
	
	player_animations.roll(input_direction, roll_invulnerability_time)
	
	if provides_iframes:
		roll_invulnerability()
	
	is_rolling = true
	
	roll_timer()
	
	disable_gun()
	
	set_on_cooldown()
	
	GameEvents.movement_ability_used.emit(self)

func roll_timer():
	await get_tree().create_timer(roll_animation_time).timeout
	if is_rolling:
		roll_end()

func roll_end():
	is_rolling = false
	enable_gun()
	
	if player_health_manager != null:
		player_health_manager.is_rolling = false

func roll_invulnerability():
	if player_health_manager == null:
		player_health_manager = get_parent().health_manager
		if player_health_manager == null:
			print_debug("Couldn't find the health manager :(")
			return
	player_health_manager.is_rolling = true
	await get_tree().create_timer(roll_invulnerability_time).timeout
	player_health_manager.is_rolling = false

func dive_end():
	is_diving = false
	enable_gun()

func disable_gun():
	player_gun.active = false
	player_gun.visible = false

func enable_gun():
	player_gun.active = true
	player_gun.visible = true

func on_jump():
	if is_rolling:
		roll_end()
	if is_diving:
		dive_end()

func on_land():
	if is_diving:
		if is_diving:
			dive_end()
		if Input.is_action_pressed("dash"):
			roll()
	
	can_dive = true
