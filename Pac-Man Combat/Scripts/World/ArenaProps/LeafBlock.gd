@tool
extends Resizer

@onready var area_shape: CollisionShape2D = $DetectionArea/CollisionShape2D

func _ready() -> void:
	navigation_region.set_deferred("enabled", false)


func _on_detection_area_body_entered(body: Node2D) -> void:
	disable_block()

func disable_block() -> void:
	collision_shape.set_deferred("disabled", true)
	sprite.visible = false
	navigation_region.set_deferred("enabled", true)

func set_editor_size():
	super.set_editor_size()
	area_shape.shape.size = collision_shape.shape.size + Vector2(8, 8)
	area_shape.position = collision_shape.position
