@tool
extends StaticBody2D

@export_range(16, 720, 16) var size: float = 64:
	set(value):
		size = value

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite
@onready var player = get_tree().get_first_node_in_group("Player")

var is_active: bool = true
var has_released_down: bool = false

func _ready() -> void:
	collision_shape = $CollisionShape2D
	
	if Engine.is_editor_hint():
		collision_shape.shape = collision_shape.shape.duplicate()
	
	set_editable_instance(collision_shape, false)
	collision_shape.shape.size.x = size
	
	if sprite == null:
		sprite = $Sprite
	sprite.region_rect.size.x = size

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		collision_shape = $CollisionShape2D
		set_editable_instance(collision_shape, false)
		collision_shape.shape.size.x = size
		
		if sprite == null:
			sprite = $Sprite
		sprite.region_rect.size.x = size
	
	if not Engine.is_editor_hint():
		if Input.is_action_pressed("move_down"):
			if is_active:
				is_active = false
				collision_shape.disabled = true
		else:
			if is_active == false && has_released_down == false:
				has_released_down = true
				
				disable_platform()

func disable_platform():
	is_active = false
	await get_tree().create_timer(0.1).timeout
	
	collision_shape.disabled = false
	is_active = true
	has_released_down = false
