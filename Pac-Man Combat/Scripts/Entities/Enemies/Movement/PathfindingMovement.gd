class_name PathfindingMovement
extends EntityMovement

var target_position: Vector2

@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var path_timer: Timer = $NavigationAgent2D/Timer

var moving = false

func _ready() -> void:
	await get_tree().create_timer(randf_range(0, 0.5)).timeout
	path_timer.timeout.connect(update_path)
	
	update_path()
	
	if(rigidbody == null):
		initialize(get_parent().owner)

func start():
	path_timer.start()
	update_path()

func stop():
	path_timer.stop()

func update(delta: float) -> void:
	if path_timer.is_stopped():
		path_timer.start()

func _physics_process(delta: float) -> void:
	if agent.is_navigation_finished():
		return
	var direction: Vector2 = global_position.direction_to(agent.get_next_path_position())
	
	if direction.y < 0:
		direction.y *= 0.7
	elif direction.y > 0:
		direction.y *= 1.1
	
	rigidbody.apply_force(direction * delta * rigidbody.linear_damp * current_speed * speed_modifier * 100)

func move_along_path(distance: float) -> void:
	pass

func update_path() -> void:
	agent.target_position = target_position
