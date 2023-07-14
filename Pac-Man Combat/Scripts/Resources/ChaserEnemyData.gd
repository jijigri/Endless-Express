class_name ChaserEnemyData
extends EnemyData

@export var level: int
@export_range(0, 1, 0.05) var min_weight: float
@export_range(0, 1, 0.05) var max_weight: float
@export var min_wave_to_spawn_in: int

func get_weight() -> float:
	randomize()
	return randf_range(min_weight, max_weight)
