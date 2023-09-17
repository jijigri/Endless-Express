class_name WanderMovement
extends PathfindingMovement

@onready var arena_manager: ArenaManager = get_tree().get_first_node_in_group("ArenaManager")

func update_path() -> void:
	if arena_manager != null:
		target_position = arena_manager.get_random_position_on_navmesh()
	super.update_path()


func _on_navigation_agent_2d_target_reached() -> void:
	update_path()


func _on_navigation_agent_2d_navigation_finished() -> void:
	update_path()
