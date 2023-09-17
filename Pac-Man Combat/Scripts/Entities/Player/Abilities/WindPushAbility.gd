extends AbilityBase

@export var gun: PlayerGun
@export var damage: float = 30.0
@export var push_force: float = 800.0
@export var armor_break_time = 3.0
@export var player_push_force: float = 540.0
@export var solid_push_force: float = 260.0

@onready var area: Area2D = $Area2D
@onready var area_collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var sprite: AnimatedSprite2D = $Area2D/Sprite
@onready var space_state = get_world_2d().direct_space_state

var start_sound = preload("res://Audio/SoundEffects/Abilities/WindPushStart.wav")
var solid_hit_sound = preload("res://Audio/SoundEffects/Abilities/WindPushHitSolid.wav")
var enemy_hit_sound = preload("res://Audio/SoundEffects/Abilities/WindPushHitEnemy.wav")

var detected_enemy_hurtboxes = []

func _process(delta: float) -> void:
	queue_redraw()

func use_ability(player_abilities: PlayerAbilities):
	area.rotation = gun.anchor.rotation
	
	CameraManager.shake(3.5, 0.1, false)
	launch_area()

func launch_area() -> void:
	#area.position = Vector2.ZERO
	#area.visible = true
	area.position = area.transform.x * (area_collision.shape.size.x / 2)
	
	sprite.stop()
	sprite.play("default")
	
	var audio_data = AudioData.new(start_sound, global_position)
	AudioManager.play_sound(audio_data)
	
	detected_enemy_hurtboxes.clear()
	var t: float = 0
	while t < 0.1:
		get_collisions()
		t += get_process_delta_time()
		await get_tree().process_frame
	
	if detected_enemy_hurtboxes.size() < 1:
		try_detect_solid()
	
	#area.visible = false

func get_collisions() -> void:
	for col in area.get_overlapping_areas():
		var collision = col
		if detected_enemy_hurtboxes.has(collision) == false:
			if collision.is_in_group("Hurtbox"):
				if collision.has_method("receive_hit"):
					if is_collision_visible(collision):
						
						var direction = area.transform.x
						var damage_data = DamageData.new(damage, col.global_position, direction * push_force, armor_break_time)
						damage_data.source = self
						collision.receive_hit(damage_data)
						detected_enemy_hurtboxes.append(collision)
						
						if col.status_effects_manager != null:
							col.status_effects_manager.set_status_effect("stagger", armor_break_time)
						
						push_player(direction, player_push_force, collision.global_position)

func try_detect_solid():
	for col in area.get_overlapping_bodies():
		var collision = col
		if collision.is_in_group("Solid") && !collision.is_in_group("Platform"):
			push_player(area.transform.x, solid_push_force, global_position)
			
			var audio_data = AudioData.new(solid_hit_sound, global_position)
			AudioManager.play_sound(audio_data)
			return

func push_player(direction: Vector2, push_force: float, hit_position: Vector2):
	if !gun.player.is_on_floor():
		gun.player.velocity = direction * -1 * push_force
		
		var sound = solid_hit_sound
		if push_force == player_push_force:
			sound = enemy_hit_sound
		var audio_data = AudioData.new(sound, hit_position)
		audio_data.volume = -6.0
		audio_data.max_distance = 1600.0
		AudioManager.play_sound(audio_data)

func is_collision_visible(collision):

	var query = PhysicsRayQueryParameters2D.create(global_position, collision.global_position, 4)
	var result = space_state.intersect_ray(query)

	if result:
		return false
	else:
		return true
