extends Node2D

func draw_empty_circle(source: CanvasItem, center: Vector2, radius: float, color: Color, resolution: int, width: float = 1.0, displacement: float = 0.0):
	draw_empty_arc(source, center, radius, 0.0, 360.0, color, resolution, width, displacement)

func draw_empty_arc(source: CanvasItem, center: Vector2, radius: float, angle_from: float, angle_to: float, color: Color, resolution: int, width: float = 1.0, displacement: float = 0.0):
	
	var points_arc = []

	for i in resolution + 1:
		var angle_point: float = deg_to_rad(angle_from + i * (angle_from - angle_to) / resolution - 90.0)
		var pos: Vector2 = Vector2(cos(angle_point), sin(angle_point))
		var disp = randf_range(0, displacement)
		points_arc.append(center + (pos) * (radius + disp))
		
		if i > 0:
			source.draw_line(points_arc[i - 1], points_arc[i], color, width)
