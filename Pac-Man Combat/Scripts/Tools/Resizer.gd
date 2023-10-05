@tool
class_name Resizer
extends StaticBody2D

@export var sprite: NinePatchRect
@export var navigation_region: NavigationRegion2D
@export var collision_shape: CollisionShape2D
@export var update_navigation: bool = true

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
	
	if update_navigation:
		if navigation_region != null:
			var offset_x = 8 if size.x > 17.0 else 4
			var offset_y = 8 if size.y > 17.0 else 4
			var size_x = clamp((size.x / 2) - offset_x, 4, 999999)
			var size_y = clamp((size.y / 2) - offset_y, 4, 999999)
			var polygon = NavigationPolygon.new()
			var outline = PackedVector2Array([
				center + Vector2(-size_x, -size_y),
				center + Vector2(-size_x, size_y),
				center + Vector2(size_x, size_y),
				center + Vector2(size_x, -size_y)
				])
			polygon.add_outline(outline)
			polygon.make_polygons_from_outlines()
			navigation_region.navigation_polygon = polygon
