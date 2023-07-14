class_name Door
extends StaticBody2D

enum DOOR_TYPE {ENTRANCE, EXIT}

@export var door_type: DOOR_TYPE = DOOR_TYPE.ENTRANCE

@onready var collision_shape: CollisionShape2D = $Shape
@onready var sprite: Sprite2D = $Sprite2D
@onready var initial_sprite_position: Vector2 = sprite.position
@onready var close_sound = preload("res://Audio/SoundEffects/Misc/DoorCloseSound.wav")

var is_open: bool = false
var arena: Arena

func _ready() -> void:
	if door_type == DOOR_TYPE.EXIT:
		var area: Area2D = $Area2D
		if area != null:
			area.body_entered.connect(_on_area_body_entered)

func initialize(arena: Arena):
	self.arena = arena
	
	if collision_shape == null:
		collision_shape = $Shape
	if sprite == null:
		sprite = $Sprite2D
	
	initial_sprite_position = sprite.position

func open():
	is_open = true
	collision_shape.set_deferred("disabled", true)
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "position", initial_sprite_position + (Vector2.UP * 48), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.play()

func close():
	is_open = false
	collision_shape.set_deferred("disabled", false)
	
	sprite.position = initial_sprite_position + (Vector2.UP * 48)
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "position", initial_sprite_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.play()
	
	await get_tree().create_timer(0.2).timeout
	on_door_closed()

func on_door_closed():
	var audio_data = AudioData.new(close_sound, global_position)
	AudioManager.play_sound(audio_data)

func _on_area_body_entered(body: Node2D):
	if is_open == false:
		return
	
	if arena == null:
		print_debug("Arena couldn't be found!")
		#TO DO, FIND BASED ON CURRENT ARENA
		arena = get_parent().get_parent()
	
	if body.is_in_group("Player"):
		print_debug("Player entered!")
		GameEvents.arena_exited.emit(arena)
		close()
