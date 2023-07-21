extends Node2D

@onready var world = get_world_2d()

var indicator_type_manager = SpawnIndicatorType.new()

var current_id: int = 0

func _ready():
	
	SilentWolf.configure({
		"api_key": "LeiUamxSvV9viEP21PsfC26VxN73ynsl2FtkO7nM",
		"game_id": "EndlessExpress",
		"log_level": 0
	})
	
	"""
	SilentWolf.configure_scores({
		"open_scene_on_close": "res://scenes/MainPage.tscn"
	})
	"""

func spawn_object(object, position: Vector2, rotation: float = 0, parent = null):
	var instance = object.instantiate()
	
	if parent == null:
		get_tree().root.get_node("Game").add_child.call_deferred(instance)
	else:
		parent.add_child(instance)
	
	instance.position = position
	instance.rotation = rotation
	
	return instance

func spawn_with_indicator(indicator_type: SpawnIndicatorType.TYPE, object, position: Vector2, rotation: float = 0, parent = null, time: float = 1.0, callable: Callable = Callable()):
	var indicator_scene: PackedScene = indicator_type_manager.scene_from_type(indicator_type)
	spawn_object(indicator_scene, position, rotation, parent)
	await get_tree().create_timer(time).timeout
	var instance = spawn_object(object, position, rotation, parent)
	if callable != Callable():
		callable.call(instance)

func swap_color(old_colors: Array[Color], new_colors: Array, mat: Material):
	
	#mat.set_shader_parameter("OLD_COLOR1", Color("fabf79"))
	#mat.set_shader_parameter("NEW_COLOR1", Color.RED)

	for i in old_colors.size():
		match i:
			0:
				mat.set_shader_parameter("OLD_COLOR1", old_colors[i])
				mat.set_shader_parameter("NEW_COLOR1", new_colors[i])
			1:
				mat.set_shader_parameter("OLD_COLOR2", old_colors[i])
				mat.set_shader_parameter("NEW_COLOR2", new_colors[i])
			2:
				mat.set_shader_parameter("OLD_COLOR3", old_colors[i])
				mat.set_shader_parameter("NEW_COLOR3", new_colors[i])
			3:
				mat.set_shader_parameter("OLD_COLOR4", old_colors[i])
				mat.set_shader_parameter("NEW_COLOR4", new_colors[i])
	
func get_point_before_collision(origin, target) -> Vector2:
	var space_state = world.direct_space_state
	var query = PhysicsRayQueryParameters2D.create(origin, target, 4)
	var result = space_state.intersect_ray(query)
	if result:
		return result.position
	else:
		return target

func get_unique_id() -> int:
	current_id += 1
	if current_id >= 9223372036854775801:
		current_id = 1
	return current_id

func wobble(object, from: Vector2, value: float, strength: float = 4.0):
	object.position = from + (Vector2(randf_range(-value, value), randf_range(-value, value)) * strength)

func wobble_offset(object, value: float, strength: float = 4.0):
	object.offset = Vector2.ZERO + (Vector2.ONE * (value * strength))
