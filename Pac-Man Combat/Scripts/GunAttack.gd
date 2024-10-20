extends EnemyAttack

@export var squared_distance_from_player_to_attack: float = 400.0
@export var distance_from_player_to_attack: float = 0.0
@export var time_between_shots: float = 0.5
@export var shot_start_time = 0.2
@export var dont_shoot_automatically: bool = false

@onready var gun: EnemyGun = $EnemyGun

@onready var player: Player = get_tree().get_first_node_in_group("Player")
@onready var current_shot_start_time = shot_start_time

var raycast: RayCast2D

var cancelled: bool = false
var is_on_cooldown: bool = false

signal attack_began
signal attack_performed
signal attack_ended

func _ready() -> void:
	raycast = get_node_or_null("RayCast2D")

func _process(delta: float) -> void:
	super._process(delta)
	
	if dont_shoot_automatically:
		return
	
	if active == false || is_locked:
		return
	
	if is_on_cooldown == false:
		
		var is_player_visible = is_player_visible()
		
		if is_player_visible():
			var distance = owner.distance_to_player
			if distance_from_player_to_attack == 0:
				if distance * distance <= squared_distance_from_player_to_attack:
					start_shooting_sequence()
			else:
				if distance <= distance_from_player_to_attack:
					start_shooting_sequence()

func start_shooting_sequence():
	cancelled = false
	is_on_cooldown = true
	
	attack_began.emit()
	
	await get_tree().create_timer(current_shot_start_time).timeout
	
	if !active || is_locked:
		on_attack_end()
		return
	
	if !cancelled:
		shoot()
	else:
		cancelled = false
		await get_tree().create_timer(time_between_shots).timeout
		is_on_cooldown = false

func shoot():
	gun.shoot(damage_multiplier, self)
	
	attack_performed.emit()
	
	await get_tree().create_timer(time_between_shots).timeout
	
	on_attack_end()

func on_attack_end():
	is_on_cooldown = false
	
	attack_ended.emit()


func _on_health_manager_armor_broken() -> void:
	cancelled = true
	current_shot_start_time = 0.5


func _on_health_manager_armor_repaired() -> void:
	cancelled = false
	current_shot_start_time = shot_start_time

func is_player_visible() -> bool:
	if raycast == null:
		return true
	
	raycast.target_position = player.global_position - global_position
	
	queue_redraw()
	
	if raycast.is_colliding():
		return false
	else:
		return true
	return false
