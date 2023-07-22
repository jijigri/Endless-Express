class_name Gun
extends Resource

enum TYPE {AUTOMATIC, MANUAL, BURST}

@export_group("General settings")
@export var damage: float = 20
@export var cooldown: float = 0.1
@export var on_switch_cooldown: float = 0.05
@export var type: TYPE = TYPE.AUTOMATIC
@export var knockback_force: float = 20.0
@export_group("Gun feel settings")
@export var shake_force: float = 1.0
@export var shake_time: float = 0.1
@export var recoil_strength_degrees: float = 30
@export var recoil_strength_pixels: float = 8
@export var muzzle_flash: PackedScene = preload("res://Scenes/Effects/shotgun_muzzleflash.tscn")
@export_group("Push settings")
@export var player_push_force: float = 0.0
@export var push_in_all_directions: bool = false
@export_group("Other settings")
@export var drop_ammo: Texture2D = AtlasTexture.new()
@export var audio: AudioStream

var initial_pos: Vector2 = Vector2(9999, 9999)

signal hit

func shoot(player_gun: Node2D, team_player: bool = true) -> void:
	
	if initial_pos == Vector2(9999, 9999):
		initial_pos = player_gun.sprite.position
	
	var particles = Global.spawn_object(player_gun.particles, player_gun.global_position)
	particles.texture = drop_ammo
	if player_gun.sprite.flip_v == true:
		particles.scale.x = -1
	particles.restart()

	Global.spawn_object(
		muzzle_flash, player_gun.spawn_point.global_position, player_gun.global_rotation
		)
	
	if audio != null:
		AudioManager.play_sound(
		AudioData.new(audio,
		player_gun.spawn_point.global_position, -3.0)
	)
	
	player_recoil(player_gun)
	
	apply_recoil(player_gun)
	
	CameraManager.shake(shake_force, shake_time)

func apply_recoil(player_gun: Node2D):
	
	var recoil_time = cooldown
	
	var rot = deg_to_rad(
	recoil_strength_degrees * ( -1 if player_gun.sprite.flip_v == false else 1)
	)
	var tween = player_gun.get_tree().create_tween()
	tween.tween_property(player_gun.sprite, "rotation", rot, recoil_time / 4).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(player_gun.sprite, "rotation",  deg_to_rad(0), recoil_time - (recoil_time / 4)).set_ease(Tween.EASE_OUT)
	tween.play()
	
	var pos_tween = player_gun.get_tree().create_tween()
	pos_tween.tween_property(player_gun.sprite, "position", initial_pos - (Vector2.RIGHT * recoil_strength_pixels), recoil_time / 4).set_trans(Tween.TRANS_ELASTIC)
	pos_tween.tween_property(player_gun.sprite, "position",  initial_pos, recoil_time).set_ease(Tween.EASE_OUT)
	pos_tween.play()

func player_recoil(player_gun: Node2D):
	if player_push_force == 0:
		return
	
	var player: PhysicsBody2D = player_gun.player
	if !Input.is_action_pressed("interact_cancel"):
		var override_velocity: Vector2 = -player_gun.transform.x * player_push_force
		if !push_in_all_directions:
			if !player.is_on_floor():
				if override_velocity.y < 0:
					override_velocity.x = 0
					if player.velocity.y > 0 && override_velocity.y < -.8:
						player.velocity.y = 0
					player.velocity += override_velocity
		else:
			player.velocity += override_velocity

func on_hit():
	hit.emit()
