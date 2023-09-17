extends Node2D

@onready var player = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	HUD.visible = true
	
	await get_tree().process_frame
	var tilemap = get_parent().get_node("Level")
	var rect = tilemap.get_used_rect()
	var margin: float = 16 * 8
	var cam = player.camera
	cam.limit_top = (rect.position.y * 16) + margin
	cam.limit_bottom = (rect.end.y * 16) - margin
	cam.limit_left = (rect.position.x * 16) + margin
	cam.limit_right = (rect.end.x * 16) - margin
	
	player.health_manager.take_damage(DamageData.new(60, Vector2.ZERO))
	player.health_manager.invincible = true
