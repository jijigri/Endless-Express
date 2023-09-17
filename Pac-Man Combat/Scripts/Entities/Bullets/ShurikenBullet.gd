extends Bullet

@export var bounce_amount: int = 4

@onready var bounces_left: int = bounce_amount
@onready var bounce_area: Area2D = $BounceArea

var passive_ability

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player != null:
		passive_ability = player.passive_ability
		if passive_ability != null:
			bounce_amount = passive_ability.current_charges
			bounces_left = bounce_amount
	
	super._ready()

func initialize(_damage: float, _speed: float, _knockback_force: float = 0, _lifetime = 0.5):
	super.initialize(_damage, _speed, _knockback_force, _lifetime)

func on_entity_damaged(area):

	if bounces_left > 0:
		bounce(area)
		bounces_left -= 1
	else:
		destroy_bullet()
	
	super.on_entity_damaged(area)

func bounce(current_target):
	
	var enemies_in_range = bounce_area.get_overlapping_areas()
	var possible_enemies = {}
	var highest_probability = 0
	
	if enemies_in_range.size() <= 0:
		destroy_bullet()
		return
	
	for enemy in enemies_in_range:
		var probability_level = 10
		if enemy.is_in_group("Chasers"):
			if enemy.health_manager.armored:
				probability_level -= 2
		else:
			probability_level -= 1
		if enemy in entities_damaged:
			probability_level -= 5
		
		if !Global.is_visible_from(global_position, enemy.global_position):
			probability_level = 0
		
		if enemy == current_target:
			probability_level = 0
		
		possible_enemies[enemy] = probability_level
		
		if probability_level > highest_probability:
			highest_probability = probability_level
	
	if highest_probability == 0:
		destroy_bullet()
		return
	
	var target = null
	var shortest_distance: float = 1000000.0
	
	for enemy in possible_enemies:
		if possible_enemies[enemy] == highest_probability:
			var dist = global_position.distance_squared_to(enemy.global_position)
			if dist < shortest_distance:
				target = enemy
				shortest_distance = dist
	
	
	if target != null:
		if target in entities_damaged:
			entities_damaged.erase(target)
		#print_debug("Target is ", target.owner.name)
		var angle = Helper.angle_between(global_position, target.global_position)
		rotation_degrees = angle
		velocity = transform.x
		
		$Lifetime.start()
	else:
		#print_debug("Target is null")
		pass
