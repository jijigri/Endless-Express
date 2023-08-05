@tool
extends Resizer

@export var keys_parent: Node2D
@export var color: int = 0

@onready var animation_player = $AnimationPlayer

@onready var unlocked_sound = preload("res://Audio/SoundEffects/ArenaProps/LockBlock/UnlockedSound.wav")
@onready var open_sound = preload("res://Audio/SoundEffects/ArenaProps/LockBlock/LockBlockOpenSound.wav")
@onready var locks: Node2D = $Locks

var colors = {
	0: [Color("f7eabe"), Color("ad879c"), Color("744a76"), Color.BLACK],
	1: [Color("f5f6cf"), Color("cddd1c"), Color("8a9b2d"), Color.BLACK],
	2: [Color("f5f6cf"), Color("d69c5f"), Color("8e5c44"), Color.BLACK],
	3: [Color("f7eabe"), Color("fabf79"), Color("ce2d73"), Color.BLACK],
	4: [Color("f5f6cf"), Color("4df15a"), Color("5165de"), Color.BLACK]
}

var keys = []

var active: bool = true

signal opened

func _ready() -> void:
	sprite = $NinePatchRect
	collision_shape = $CollisionShape2D
	navigation_region = $NavigationRegion2D
	collision_shape.shape = collision_shape.shape.duplicate()
	sprite.texture = sprite.texture.duplicate()
	
	if Engine.is_editor_hint() == true:
		return
	
	set_color()
	
	if locks == null:
		locks = $Locks
	
	if keys_parent == null:
		keys_parent = $Keys
	
	for i in keys_parent.get_children():
		i.obtained.connect(on_key_obtained)
		keys.append(i)
		
		if color != 0:
			var sprite = i.get_node("Sprite2D")
			sprite.material = sprite.material.duplicate()
			sprite.material.set_shader_parameter("STRENGTH", 1.0)
			Global.swap_color(colors.get(0), colors.get(color), sprite.material)
	
	if locks.get_child_count() > keys.size():
		for i in locks.get_child_count() - keys.size():
			print_debug("Removing lock")
			locks.get_child(i).queue_free()
			

func set_color():
	if color != 0:
		sprite.material = sprite.material.duplicate()
		sprite.material.set_shader_parameter("STRENGTH", 1)
		Global.swap_color(colors.get(0), colors.get(color), sprite.material)

func on_key_obtained(key):
	if active:
		keys.erase(key)
		
		if keys.size() < 1:
			open()
		
		locks.get_child(keys.size() - 1).play("unlocked")
		
		var audio_data = AudioData.new(unlocked_sound, global_position)
		audio_data.max_distance = 4000
		audio_data.volume = 2
		AudioManager.play_sound(audio_data)

func open():
	if Engine.is_editor_hint():
		return
	
	animation_player.play("open")
	
	collision_shape.set_deferred("disabled", true)
	navigation_region.set_deferred("enabled", true)
	
	var audio_data = AudioData.new(open_sound, global_position)
	audio_data.max_distance = 1000
	audio_data.attenuation = 0.25
	AudioManager.play_sound(audio_data)
	
	opened.emit()
	
	active = false
