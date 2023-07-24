@tool
class_name Resizer
extends StaticBody2D

@export var sprite: NinePatchRect
@export var navigation_region: NavigationRegion2D
@export var collision_shape: CollisionShape2D

func _ready() -> void:
	collision_shape = $CollisionShape2D

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		set_editor_size()

func set_editor_size():
	if sprite == null:
		sprite = $NinePatchRect
		
	if collision_shape == null:
		collision_shape = $CollisionShape2D
	
	var size: Vector2 = collision_shape.shape.size
	var center: Vector2 = collision_shape.position
	
	if sprite != null:
		sprite.size = size
		sprite.position = Vector2(-size.x / 2, -size.y / 2) + center
		sprite.pivot_offset = size / 2
	
	if navigation_region != null:
		var polygon = NavigationPolygon.new()
		var outline = PackedVector2Array([
			center + Vector2(-size.x / 2, -size.y / 2),
			center + Vector2(-size.x / 2, size.y / 2),
			center + Vector2(size.x / 2, size.y / 2),
			center + Vector2(size.x / 2, -size.y / 2)
			])
		polygon.add_outline(outline)
		polygon.make_polygons_from_outlines()
		navigation_region.navigation_polygon = polygon
