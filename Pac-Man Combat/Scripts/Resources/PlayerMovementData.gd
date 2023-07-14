class_name PlayerMovementData
extends Resource

@export var speed: float = 240.0
@export var initial_gravity: float = 1200.0
@export var jump_force: float = 370.0
@export var ground_acceleration: float = 0.18
@export var ground_deceleration: float = 0.25
@export var air_acceleration: float = 0.15
@export var air_deceleration: float = 0.0
@export var jump_apex_treshold: float = 50.0
@export var jump_apex_gravity_multiplier: float = 0.5
@export var fall_gravity_multiplier: float = 1.5
@export var max_gravity: float = 1600.0
@export var coyote_time: float = 0.125
@export var buffered_jump_time: float = 0.15
@export var initial_number_of_jumps: int = 1
@export var dash_force: float = 600
@export var dash_time: float = 0.1
@export var initial_number_of_dashes: int = 0
@export var max_wall_slide_gravity: float = 220.0
@export var wall_jump_force: Vector2 = Vector2(300, 460)
