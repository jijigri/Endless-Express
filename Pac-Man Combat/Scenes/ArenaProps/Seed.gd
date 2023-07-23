class_name Seed
extends RigidBody2D

@export var type: TargetEnemyData.TYPE
@export var randomize_type: bool = true
@export var drop_pool: TargetDropPool
@export var color_swap: ColorSwap

@onready var sprite = $Sprite
@onready var health_manager: HealthManager = $HealthManager

@onready var activated_sound = preload("res://Audio/SoundEffects/ArenaProps/Seeds/SeedsActivatedSound.wav")

func _ready() -> void:
	
	if get_parent() is LeafBlock:
		set_static()
		get_parent().broke.connect(set_dynamic)
	
	var collision_shape = $CollisionShape2D
	collision_shape.shape = collision_shape.shape.duplicate()
	
	var hurtbox_shape = $Hurtbox/CollisionShape2D
	hurtbox_shape.shape = hurtbox_shape.shape.duplicate()
	
	sprite.material = sprite.material.duplicate()
	
	if randomize_type:
		type = randi_range(0, TargetEnemyData.TYPE.size() - 1)
	set_type()

func set_static():
	set_deferred("freeze", true)

func set_type() -> void:
	var default_colors = color_swap.default_colors
	var replace_color = color_swap.replace_colors[type]
	Global.swap_color(default_colors, replace_color, sprite.material)

func _on_health_manager_entity_killed() -> void:
	if freeze == false:
		kill()
	else:
		health_manager.current_health = health_manager.max_health
		health_manager.active = true

func kill():
	drop()
	
	var instance = Global.spawn_object(ScenesPool.shockwave, global_position)
	instance.initialize(0.26, 6.0, 0.5, 0.18)
	
	queue_free()

func drop():
	if drop_pool.drops_in_enum_order.size() > type:
		var current_pool: DropPool = drop_pool.drops_in_enum_order[type]
		for item in current_pool.pool:
			var scene = item.scene
			for i in item.amount:
				Global.spawn_object(scene, global_position)

func set_dynamic():
	set_deferred("freeze", false)
	
	var audio_data = AudioData.new(
			activated_sound,
			global_position
		)
	audio_data.max_distance = 1000
	AudioManager.play_sound(audio_data)
