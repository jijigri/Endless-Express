class_name MouseCursor
extends CanvasLayer

@onready var cursor: Sprite2D = $Cursor
@onready var animation_player: AnimationPlayer = $Cursor/AnimationPlayer
@onready var tiled_bar: PackedScene = preload("res://Scenes/Tools/tiled_bar.tscn")
@onready var energy_bar_point: Node2D = $Cursor/EnergyBarPoint

var current_energy_bar: TiledBar = null

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	GameEvents.enemy_damaged.connect(on_enemy_damaged)
	GameEvents.enemy_killed.connect(on_enemy_killed)
	pass

func _process(delta: float) -> void:
	cursor.global_position = cursor.get_global_mouse_position()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animation_player.play("default")

func on_enemy_damaged(enemy: Enemy):
	if animation_player.current_animation != "kill":
		animation_player.play("hit")
	
func on_enemy_killed(enemy: Enemy):
	animation_player.play("kill")

func display_ability_cost(current_energy: float, required_energy: float):
	if current_energy_bar != null:
		current_energy_bar.queue_free()
	
	var instance = Global.spawn_object(tiled_bar, energy_bar_point.position, 0, cursor)
	instance.position.x = -((required_energy * 0.4642857143) / 2) / 2
	instance.max_value = (required_energy * 0.4642857143) / 2
	instance.value = (current_energy * 0.4642857143) / 2
	current_energy_bar = instance
	destroy_energy_bar(0.5)

func destroy_energy_bar(delay: float):
	var tween = create_tween()
	tween.tween_property(current_energy_bar, "modulate:a", 0, delay).set_delay(0.1)
	tween.tween_callback(free_energy_bar)
	tween.play()

func free_energy_bar():
	if current_energy_bar != null:
		current_energy_bar.queue_free()
