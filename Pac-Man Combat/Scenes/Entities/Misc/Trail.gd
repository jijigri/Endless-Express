extends Line2D

@export var target: Node2D = null
@export var length = 20

var point = Vector2()
var emitting: bool = true

func _physics_process(_delta: float) -> void:
	global_position = Vector2(0,0)
	global_rotation = 0
	
	if target != null:
		point = target.global_position
	else:
		point = get_parent().global_position
	
	if emitting:
		add_point(point)
	
	while get_point_count()>length:
		remove_point(0)
