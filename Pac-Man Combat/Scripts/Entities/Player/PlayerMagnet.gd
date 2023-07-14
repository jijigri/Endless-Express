extends Area2D

@export var radius: float = 24.0

@onready var player = get_parent()
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	collision_shape.shape.radius = radius

func _process(_delta: float) -> void:
	var radius_extend_size = 0.0
	if !player.is_on_floor():
		radius_extend_size += radius * 0.4
	
	radius_extend_size += clamp(player.velocity.length() * 0.06, 0, 24)
	
	collision_shape.shape.radius = radius + radius_extend_size

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("magnet_to_player"):
		area.magnet_to_player(player)
	elif area.get_parent().has_method("magnet_to_player"):
		area.get_parent().magnet_to_player(player)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("magnet_to_player"):
		body.magnet_to_player(player)
