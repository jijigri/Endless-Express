class_name ProjectileGun
extends Gun

@export_category("Projectile Gun settings")
@export var projectile: PackedScene
@export var projectile_speed: float = 500.0
@export var projectiles_per_shot: int = 1
@export var spread: float = 10
@export var burst_count: int = 1
@export var time_between_bursts: float = 0.1
@export_range(0, 1.0, 0.05) var accuracy: float = 1.0
@export var bullet_lifetime: float = 1.0
@export var ignore_iframes: bool = true

@export_group("Ultracharge Settings")
@export var ultracharge_projectile: PackedScene

func shoot(player_gun: Node2D, team_player: bool = true, ultracharge: int = 0):
	

	var id = Global.get_unique_id()
	
	for burst in burst_count:
		if !can_shoot:
			return
		
		var angle_offset: float = 0;
		var current_spread: float = spread / projectiles_per_shot;
		angle_offset -= (current_spread * (projectiles_per_shot - 1)) / 2;
		
		for i in projectiles_per_shot:
			if player_gun == null:
				return
			
			var spawn_point = Global.get_point_before_collision(player_gun.global_position, player_gun.spawn_point.global_position)
			
			var accuracy_error = lerpf(0.0, 90.0, 1 - accuracy)
			
			var projectile_to_spawn = projectile if !ultracharge_next_shot || ultracharge_projectile == null else ultracharge_projectile
			var bullet_instance: Bullet = Global.spawn_object(
				projectile_to_spawn,
				spawn_point,
				player_gun.anchor.rotation + deg_to_rad(angle_offset + 90 + randf_range(-accuracy_error / 2, accuracy_error / 2))
				)
			bullet_instance.initialize(damage, projectile_speed, knockback_force, bullet_lifetime)
			
			bullet_instance.gun_origin = self
			
			if ignore_iframes:
				bullet_instance.set_meta("unique_id", id)

			bullet_instance.set_team(team_player)
			
			angle_offset += current_spread
		
		super.shoot(player_gun)
		
		await player_gun.get_tree().create_timer(time_between_bursts).timeout
