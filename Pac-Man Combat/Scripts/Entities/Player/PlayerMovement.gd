class_name PlayerMovement
extends CharacterBody2D

@export var movement_data: PlayerMovementData

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var gravity: float = movement_data.initial_gravity

var direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ONE
var last_movement_direction_x: int = 1
var last_wall_direction: int = -1
var lastPressedDirection: int = 0

var isJumping: bool = false
var canLand: bool = false

var lastVelocity: Vector2

var process_movement: bool = true
var lock_horizontal_movement: bool = false
var lock_wall_slide: bool = false

var is_wall_sliding = false

var landTween: Tween
var justDashed: bool

var speed_modifier: float = 1.0

var is_dashing = false

var jumped_this_frame: bool

@onready var numberOfJumpsLeft: int = 0
@onready var number_of_dashes_remaining: int = movement_data.initial_number_of_dashes

var currentcoyote_time: float
var currentbuffered_jump_time: float

signal moved(velocity)

signal jumped
signal landed

signal on_dash_begin
signal on_dash_finish

func _process(delta):
	jumped_this_frame = false
	if is_dashing == false:
		process_coyote_and_buffered_time(delta)
		get_x_input()
		get_y_input()
		
	if Input.is_action_just_pressed("dash"):
		if number_of_dashes_remaining > 0:
			pass
			#dash()
		
	
	if direction != Vector2.ZERO:
		last_direction = direction
	
	if abs(velocity.x) > 0.1:
		last_movement_direction_x = velocity.x
	
func _physics_process(delta):
	
	if is_dashing:
		move_and_slide()
		moved.emit(velocity)
		return
	
	check_wall_sliding()
	set_gravity()

	if process_movement:
		
		if not is_on_floor():
			air_behavior(delta)
		
		var wasInTheAir = not is_on_floor()
		move_player(delta)
		var justLanded = is_on_floor() && wasInTheAir
		var justOffGround = not is_on_floor() && not wasInTheAir
		
		if justLanded:
			on_land()
		
		if justOffGround:
			on_off_ground()
	
	moved.emit(velocity)
	
	justDashed = false
	
	lastVelocity = velocity

func get_x_input():
	
	if Input.is_action_just_pressed("move_left"):
		lastPressedDirection = -1
	if Input.is_action_just_pressed("move_right"):
		lastPressedDirection = 1
	
	var leftPressed: bool = Input.is_action_pressed("move_left")
	var rightPressed: bool = Input.is_action_pressed("move_right")
	
	if leftPressed:
		if rightPressed:
			if lastPressedDirection == -1:
				direction.x = -1
		else:
			direction.x = -1
		
	if rightPressed:
		
		if leftPressed:
			if lastPressedDirection == 1:
				direction.x = 1
		else:
			direction.x = 1
	
	
	
	if not leftPressed && not rightPressed:
		direction.x = 0
	
	pass

func get_y_input():
	
	if Input.is_action_pressed("move_up"):
		direction.y = -1
	elif Input.is_action_pressed("move_down"):
		direction.y = 1
	else:
		direction.y = 0
	
	if Input.is_action_just_pressed("jump"):
		if is_wall_sliding:
			wall_jump()
			return
		
		if numberOfJumpsLeft > 0 || is_coyote_jump_possible():
			jump()
			currentcoyote_time = 0
		else:
			currentbuffered_jump_time = movement_data.buffered_jump_time;

	if numberOfJumpsLeft > 0:
		if is_jump_bufferd():
			if Input.is_action_pressed("jump"):
				jump()
			else:
				jump()
				cut_jump()
	
			currentbuffered_jump_time = 0;
		
		if !isJumping && is_on_floor():
			currentcoyote_time = movement_data.coyote_time;
	
	if is_wall_sliding:
		if is_jump_bufferd():
			wall_jump()
			currentbuffered_jump_time = 0;

	if isJumping && velocity.y < 0:
		if Input.is_action_just_released("jump"):
			cut_jump()
	
	pass

func jump():
	
	velocity.y = -movement_data.jump_force
	isJumping = true
	
	AudioManager.play_sound(
		AudioData.new(preload("res://Audio/SoundEffects/Player/PlayerJump.wav"),
		global_position)
	)
	
	if abs(velocity.x) < 100:
		var effect = Global.spawn_object(preload("res://Scenes/Effects/up_jump_effect.tscn"), global_position)
		effect.scale.x = sign(velocity.x)
	else:
		var effect = Global.spawn_object(preload("res://Scenes/Effects/side_jump_effect.tscn"), global_position)
		effect.scale.x = sign(velocity.x)
	
	jumped.emit()
	jumped_this_frame = true
	
	if not is_on_floor() && not is_coyote_jump_possible():
		numberOfJumpsLeft -= 1

	pass

func wall_jump():
	velocity = Vector2(movement_data.wall_jump_force.x * -last_wall_direction, movement_data.wall_jump_force.y * -1)
	
	AudioManager.play_sound(
		AudioData.new(preload("res://Audio/SoundEffects/Player/PlayerJump.wav"),
		global_position)
	)
	
	var effect = Global.spawn_object(preload("res://Scenes/Effects/wall_jump_effect.tscn"), global_position)
	effect.scale.x = sign(velocity.x)

func cut_jump():

	velocity.y = velocity.y / 2
	
	pass

func air_behavior(delta: float):
	
	if landTween != null:
			if landTween.is_running():
				landTween.stop()
		
	var strength = abs(velocity.y) / 2600
	strength = clamp(strength, 0, 0.2)
	sprite.scale = Vector2(1 - (strength * 1.2), 1 + strength)
	#print("Strength",strength)

func set_gravity():
	if abs(velocity.y) < movement_data.jump_apex_treshold:
		gravity = movement_data.initial_gravity * movement_data.jump_apex_gravity_multiplier
	elif velocity.y < 0:
		gravity = movement_data.initial_gravity
	elif velocity.y >= 0:
		gravity = movement_data.initial_gravity * movement_data.fall_gravity_multiplier

func move_player(delta: float):
	
	horizontal_movement()
	velocity.y += gravity * delta
	
	if is_wall_sliding == false:
		if(velocity.y > movement_data.max_gravity):
			velocity.y = movement_data.max_gravity
	else:
		if(velocity.y > movement_data.max_wall_slide_gravity):
			velocity.y = movement_data.max_wall_slide_gravity
	
	move_and_slide()
	pass

func horizontal_movement():
	if lock_horizontal_movement:
		return
	
	var targetSpeed: float = direction.x * movement_data.speed * speed_modifier

	var accelRate: float;

	if is_on_floor() && justDashed == false:
		accelRate = movement_data.ground_acceleration if abs(targetSpeed) > 0.01 else movement_data.ground_deceleration
	else:
		if abs(targetSpeed) > 0.01:
			if abs(velocity.x) <= movement_data.speed:
				accelRate = movement_data.air_acceleration
			else:
				accelRate = 0.05
		else:
			if abs(velocity.x) <= movement_data.speed:
				accelRate = movement_data.air_deceleration
			else:
				accelRate = 0

	var speedDif: float = targetSpeed - velocity.x

	var movement: float = speedDif * accelRate

	velocity.x += movement
	
func on_off_ground():
	if not justDashed:
		numberOfJumpsLeft -= 1

func on_land():
	
	numberOfJumpsLeft = movement_data.initial_number_of_jumps
	
	var tweenStrength: float = abs(lastVelocity.y) / 1100
	tweenStrength = clamp(tweenStrength, .2, .8)
	landTween = create_tween()
	landTween.tween_property(sprite, "scale", Vector2(1 + (tweenStrength * 1.2), 1 - tweenStrength), .1)
	landTween.tween_property(sprite, "scale", Vector2(1, 1), .1)
	landTween.play()
	
	AudioManager.play_sound(
		AudioData.new(preload("res://Audio/SoundEffects/Player/PlayerLand.wav"),
		global_position, -5.0)
	)
	
	Global.spawn_object(preload("res://Scenes/Effects/land_particles.tscn"), global_position)
	
	landed.emit()
	
	refill_dashes()
	
	isJumping = false
	pass

func on_step():
	pass
 
func check_wall_sliding() -> void:
	if lock_wall_slide:
		is_wall_sliding = false
		return
	
	var space_state = get_world_2d().direct_space_state
	var direction: Vector2 = Vector2(sign(last_movement_direction_x), 0)
	
	var colliding_with_wall: bool = false
	
	for i in 4:
		var start_position: Vector2 = (global_position - (Vector2(0, 10 * i - 16)))
		
		var query = PhysicsRayQueryParameters2D.create(
		start_position, start_position + (direction * (8 + safe_margin)), 8 + 5, [self]
		)
		var result = space_state.intersect_ray(query)
		
		if result.size() > 0:
			colliding_with_wall = true
	
	is_wall_sliding = colliding_with_wall && !is_on_floor() && !Input.is_action_pressed("move_down")
	
	if is_wall_sliding:
		last_wall_direction = sign(last_movement_direction_x)

func dash() -> void:
	is_dashing = true
	number_of_dashes_remaining -= 1
	velocity = last_direction.normalized() * movement_data.dash_force
	
	await get_tree().create_timer(movement_data.dash_time).timeout
	
	velocity = last_direction.normalized() * 200
	is_dashing = false

func dash_to_position(pos: Vector2, dist: float):
	
	var vel: Vector2 = position.direction_to(pos).normalized()
	var dashSpeed: float = 1200
	
	var tween = create_tween()
	var duration: float = dist / dashSpeed
	tween.tween_property(self, "position", pos, duration)
	var callable = Callable(self, "on_dash_end")
	tween.tween_callback(on_dash_end.bind(vel, dashSpeed))
	tween.play()
	
	on_dash_begin.emit()
	
	process_movement = false

func on_dash_end(direction: Vector2, dashSpeed: float):
	justDashed = true
	
	print("Player: dash ended")
	velocity = Vector2()
	velocity = direction * (dashSpeed * 0.3)
	
	numberOfJumpsLeft = movement_data.initial_number_of_jumps - 1
	
	on_dash_finish.emit()
	
	process_movement = true

func bounce(vel: Vector2):
	numberOfJumpsLeft = movement_data.initial_number_of_jumps - 1
	velocity = vel

func process_coyote_and_buffered_time(delta) -> void:
	if currentcoyote_time > 0:
		currentcoyote_time -= delta
		
	if currentbuffered_jump_time > 0:
		currentbuffered_jump_time -= delta

func is_coyote_jump_possible() -> bool:
	return currentcoyote_time > 0

func is_jump_bufferd() -> bool:
	return currentbuffered_jump_time > 0

func refill_dashes():
	number_of_dashes_remaining = movement_data.initial_number_of_dashes

func modify_speed(speed: float, time: float):
	speed_modifier = speed
	await get_tree().create_timer(time).timeout
	speed_modifier = 1.0

func modify_speed_smooth(speed: float, time: float):
	speed_modifier = speed
	var tween = create_tween()
	tween.tween_property(self, "speed_modifier", 1.0, time)

func _on_draw() -> void:
	
	return
	
	var direction: Vector2 = Vector2(sign(last_direction.x), 0)
	
	for i in 4:
		var start_position: Vector2 = (global_position - (Vector2(0, 10 * i - 16)))
		
		var target_position = start_position + (direction * (32 + safe_margin))
		draw_line(start_position, target_position, Color.CRIMSON, 1)
