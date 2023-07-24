@tool
extends Resizer

@export var keys_parent: Node2D

@onready var animation_player = $AnimationPlayer

@onready var unlocked_sound = preload("res://Audio/SoundEffects/ArenaProps/LockBlock/UnlockedSound.wav")
@onready var open_sound = preload("res://Audio/SoundEffects/ArenaProps/LockBlock/LockBlockOpenSound.wav")
@onready var locks: Node2D = $Locks


var keys = []

var active: bool = true

signal opened

func _ready() -> void:
	if Engine.is_editor_hint() == true:
		return
	
	if locks == null:
		locks = $Locks
	
	if keys_parent == null:
		keys_parent = $Keys
	
	for i in keys_parent.get_children():
		i.obtained.connect(on_key_obtained)
		keys.append(i)
	
	if locks.get_child_count() > keys.size():
		for i in locks.get_child_count() - keys.size():
			locks.get_child(locks.get_child_count() - 1).queue_free()

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
