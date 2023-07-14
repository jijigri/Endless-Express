@tool
extends TileMap

@export var generate_map: bool = false:
	# Update speed and reset the rotation.
	set(value):
		generate_map = false
		generate_navigation_map()

func generate_navigation_map():
	print_debug("GENERATING MAP")
	
	if !Engine.is_editor_hint():
		return
	
	clear()
	
	var tilemap: TileMap = get_parent().get_node("Level")
	var arena_rect: Rect2i = tilemap.get_used_rect()

	for x in arena_rect.size.x:
		for y in arena_rect.size.y:
			
			var pos = Vector2i(x + arena_rect.position.x, y + arena_rect.position.y)
			
			if tilemap.get_cell_source_id(0, pos) == -1:
				var has_surrounding = has_neighbours(pos, tilemap)
				
				if has_surrounding == false:
					set_cell(0, pos, 0, Vector2())

func has_neighbours(pos: Vector2i, tilemap: TileMap) -> bool:
	var found_neighbour := false
	
	if tilemap.get_cell_source_id(0, pos - Vector2i(-1, 0)) != -1:
		found_neighbour = true
	if tilemap.get_cell_source_id(0, pos - Vector2i(1, 0)) != -1:
		found_neighbour = true
	if tilemap.get_cell_source_id(0, pos - Vector2i(0, -1)) != -1:
		found_neighbour = true
	if tilemap.get_cell_source_id(0, pos - Vector2i(0, 1)) != -1:
		found_neighbour = true
	
	if tilemap.get_cell_source_id(0, pos - Vector2i(-1, -1)) != -1:
		found_neighbour = true
	if tilemap.get_cell_source_id(0, pos - Vector2i(1, 1)) != -1:
		found_neighbour = true
	if tilemap.get_cell_source_id(0, pos - Vector2i(1, -1)) != -1:
		found_neighbour = true
	if tilemap.get_cell_source_id(0, pos - Vector2i(-1, 1)) != -1:
		found_neighbour = true
	
	return found_neighbour
