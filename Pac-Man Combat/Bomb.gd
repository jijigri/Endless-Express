extends RigidBody2D

@export var explosion_scene: PackedScene
@export var explosion_radius: float = 128
@export var explosion_damage: float = 20
@export var armor_break_time: float = 5.0

var is_active: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func initialize(radius: float, damage: float):
	explosion_radius = radius
	explosion_damage = damage

func _on_body_entered(body: Node):
	if !is_active:
		return
	
	if body.is_in_group("Enemies") || body.is_in_group("Solid"):
		explode()

func explode():
	var instance = Global.spawn_object(explosion_scene, global_position)
	instance.initialize(explosion_radius, explosion_damage, armor_break_time)
	is_active = false
	
	queue_free()
