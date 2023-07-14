class_name DashMovement
extends PlayerTrackingMovement

enum State {PATHFINDING, STARTING_DASH, DASHING, STUNNED}

@export var start_time: float = 2.0
@export var dash_speed: float = 800
@export var dash_distance: float = 64.0
@export var target_speed: float = 50.0
@export var distance_from_player_to_dash = 32.0
@export var speed_gain_over_time: float = 0.1
@export var stun_time = 1.0

@onready var line: Line2D = $Line2D
@onready var raycast: RayCast2D = $RayCast2D

var can_attack: bool = true

var direction: Vector2 = Vector2()
var initial_position: Vector2

var state: State = State.PATHFINDING

var speed_over_time_modifier = 1.0

signal pathfinding_began
signal charge_began
signal dash_began
signal dash_ended

func initialize(owner: RigidBody2D):
	super.initialize(owner)

func start():
	super.start()

func target_player():

	state = State.STARTING_DASH
	
	charge_began.emit()
	
	speed_over_time_modifier = 1.0
	
	line.visible = true
	
	direction = global_position.direction_to(player.global_position).normalized()
	
	raycast.target_position = (direction * dash_distance)
	
	var pos
	if raycast.is_colliding() == false:
		pos = position + (direction * dash_distance)
	else:
		pos = raycast.get_collision_point() - global_position
	line.set_point_position(1, pos)
	
	var tween = create_tween()
	tween.tween_method(dash_startup, 5.0, 0.0, start_time)
	tween.tween_callback(start_dash)

func dash_startup(value: float) -> void:
	
	if rigidbody.status_effects_manager != null:
		if rigidbody.status_effects_manager.has_effect("freeze"):
			return
	
	line.width = value
	

func start_dash():
	line.visible = false
	
	initial_position = global_position
	state = State.DASHING
	
	dash_began.emit()
	
	dash_out()

func dash_out():
	await get_tree().create_timer(stun_time + 0.65).timeout
	if state == State.DASHING:
		state = State.STUNNED
		dash_stun()

func stop():
	state = State.PATHFINDING

func _process(delta: float) -> void:
	
	if state == State.PATHFINDING:
		pathfinding_process(delta)
	
	elif state == State.STARTING_DASH:
		current_speed = target_speed

func _physics_process(delta: float) -> void:
	if state == State.PATHFINDING || state == State.STARTING_DASH:
		super._physics_process(delta)
	
	elif state == State.DASHING:
		dash_process(delta)

func pathfinding_process(delta):
	super._process(delta)
	
	current_speed *= speed_over_time_modifier
	
	speed_over_time_modifier += delta * speed_gain_over_time
	
	direction = global_position.direction_to(player.global_position).normalized()
	
	var dist = clamp(dash_distance, 0, rigidbody.distance_to_player)
	raycast.target_position = (direction * dist)
	
	if can_attack:
		if !raycast.is_colliding() && rigidbody.distance_to_player < distance_from_player_to_dash:
			target_player()

func dash_process(delta):
	rigidbody.apply_force(direction * delta * rigidbody.linear_damp * dash_speed * speed_modifier * 100)
	if global_position.distance_to(initial_position) > dash_distance:
		
		rigidbody.linear_velocity = Vector2()
		
		state = State.STUNNED
		dash_stun()

func dash_stun():
	dash_ended.emit()
	await get_tree().create_timer(1.0).timeout
	state = State.PATHFINDING
	pathfinding_began.emit()


func _on_chaser_eagle_body_entered(body: Node) -> void:
	if state == State.DASHING:
		if body.is_in_group("Solid"):
			state = State.STUNNED
			dash_stun()


func _on_status_effects_manager_effect_removed(effect) -> void:
	if effect == "freeze":
		state = State.PATHFINDING
		pathfinding_began.emit()
		can_attack = true


func _on_status_effects_manager_effect_applied(effect, duration) -> void:
	if effect == "freeze":
		state = State.PATHFINDING
		pathfinding_began.emit()
		can_attack = false
