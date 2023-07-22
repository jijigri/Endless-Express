@tool
extends Node2D

@export var size: int = 64

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_manager: HealthManager = $HealthManager
@onready var seed_slot0 = $Leaves/SeedSlot0
@onready var seed_slot1 = $Leaves/SeedSlot1

var sprite: NinePatchRect
var hurt_box_shapes
var leaves

var seeds = []

func _ready() -> void:
	set_variables()
	edit_size()
	if Engine.is_editor_hint() == false:
		set_seeds()

func set_variables():
	sprite = $NinePatchRect
	hurt_box_shapes = [$TrunkHurtbox/CollisionShape2D, $Leaves/LeavesHurtbox/CollisionShape2D]
	leaves = $Leaves
	
	for i in hurt_box_shapes:
		i.shape = i.shape.duplicate()

func _process(delta: float) -> void:
	if Engine.is_editor_hint() == false:
		return
	
	edit_size()

func edit_size():
	if sprite == null:
		set_variables()
	
	size = clamp(size, 112, 9999)
	var clamped_size = clamp(size, 122, 9999)
	
	sprite.size.y = size
	sprite.position.y = -clamped_size + 64
	
	leaves.position.y = -clamped_size + 104
	
	hurt_box_shapes[0].shape.size.y = clamped_size - 64
	hurt_box_shapes[0].position.y = ((-clamped_size) / 2) + 64

func set_seeds() -> void:
	var slot_index: int = 0
	for i in get_children():
		if i is Seed:

			print_debug("Seed found ", slot_index)
			if slot_index == 0:
				i.reparent(seed_slot0)
				i.position = Vector2()
			elif slot_index == 1:
				i.reparent(seed_slot1)
				i.position = Vector2()
			else:
				return
				
			if i.has_method("set_static"):
				i.set_static()
			seeds.append(i)
			
			slot_index += 1
	
	if seeds.size() < 1:
		for shape in hurt_box_shapes:
			shape.set_deferred("disabled", true)

func _on_bounce_pad_bounced() -> void:
	wobble_tree()

func wobble_tree():
	animation_player.play("wobble")
	detach_seeds()

func shake_tree():
	if seeds.size() > 0:
		animation_player.play("shake")
		detach_seeds()

func detach_seeds():
	if Engine.is_editor_hint():
		return
	
	if seeds.size() < 1:
		return
	
	for seed in seeds:
		if seed.has_method("set_dynamic"):
			seed.set_dynamic()
	
	seeds.clear()
	
	for shape in hurt_box_shapes:
		shape.set_deferred("disabled", true)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if Engine.is_editor_hint():
		return
	
	if anim_name != "default":
		animation_player.play("default")



func _on_health_manager_health_updated(current_health, max_health, damage_data) -> void:
	health_manager.current_health = max_health
	shake_tree()
