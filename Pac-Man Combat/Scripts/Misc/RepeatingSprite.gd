@tool
extends Node2D

@export_range(0, 8000, 32) var size: float = 640
@export var speed: float = 800
@export var go: bool: set = set_go

@onready var sprite: NinePatchRect = $Sprite
@onready var sprite2: NinePatchRect = $Sprite2
@onready var sprite3: NinePatchRect = $Sprite3

func set_go(value):
	go = false
	
	if get_child_count() < 4:
		sprite = $Sprite
		var node = sprite.duplicate(8)
		add_child(node)

func _process(delta: float) -> void:
	if sprite == null:
		sprite = $Sprite
	if sprite2 == null:
		sprite2 = $Sprite2
	if sprite3 == null:
		sprite3 = $Sprite3
	
	sprite.position.x -= speed * delta
	sprite2.position.x -= speed * delta
	sprite3.position.x -= speed * delta
	
	if sprite.position.x < -sprite.size.x * 2:
		sprite.position.x = sprite3.position.x + sprite3.size.x
	if sprite2.position.x < -sprite2.size.x * 2:
		sprite2.position.x = sprite.position.x + sprite.size.x
	if sprite3.position.x < -sprite3.size.x * 2:
		sprite3.position.x = sprite2.position.x + sprite2.size.x
