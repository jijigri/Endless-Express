class_name CloseRangeAttack
extends EnemyAttack

@export var damage: float = 45.0
@export var range: float = 20.0
@export var active_time: float = 0.0 #0.0 = only active for one frame
@export var warmup_time: float = 0.2
@export var end_lag: float = 0.5
@export var automatic: bool = true

@onready var distance_to_attack: float = range
@onready var hitbox: Area2D = $Hitbox
@onready var sprite: Sprite2D = hitbox.get_node("Sprite2D")
@onready var animation: AnimatedSprite2D = hitbox.get_node("Animation")

@onready var player: Player = get_tree().get_first_node_in_group("Player")

var is_in_attack_sequence: bool = false
var check_for_hits: bool = false

var distance: float

signal attack_started
signal attack_performed
signal attack_ended

func _ready() -> void:
	sprite.visible = false
	animation.visible = false

func _process(_delta: float) -> void:
	super._process(_delta)
	
	if automatic:
		if rigidbody != null:
			distance = rigidbody.distance_to_player
		else:
			distance = global_position.distance_to(player.global_position)
			print_debug("Attack doesn't have a rigidbody attached via initialize()")
		
		if is_in_attack_sequence == false:
				
			if distance <= distance_to_attack:
				start_attack_sequence()

func start_attack_sequence():
	if !active || is_locked:
		return
	
	is_in_attack_sequence = true
	sprite.visible = true
	
	attack_started.emit()
	
	await get_tree().create_timer(warmup_time).timeout
	
	if !active || is_locked:
		return
	
	var direction_to_player: Vector2 = global_position.direction_to(player.global_position).normalized()
	hitbox.position = direction_to_player * clamp(distance, 0, range)
	hitbox.rotation_degrees = Helper.angle_between(hitbox.global_position, global_position)
	
	animation.stop()
	animation.play("default")
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	attack()

func attack():
	if !active || is_locked:
		return
	
	check_for_hits = true
	
	attack_performed.emit()
	
	animation.visible = true
	
	if active_time == 0.0:
		hit_detection()
		on_attack_end()
	else:
		await get_tree().create_timer(active_time).timeout
		on_attack_end()

func on_attack_end():
	check_for_hits = false
	disable_debug_sprite()
	
	await get_tree().create_timer(end_lag).timeout
	is_in_attack_sequence = false
	
	attack_ended.emit()
	
	animation.visible = false

func disable_debug_sprite():
	await get_tree().create_timer(0.15).timeout
	sprite.visible = false

func hit_detection():
	
	var overlapping_areas = hitbox.get_overlapping_areas()
	for i in overlapping_areas:
		if i.is_in_group("Hurtbox"):
			var damage_data = DamageData.new(damage, hitbox.global_position)
			i.receive_hit(damage_data)
