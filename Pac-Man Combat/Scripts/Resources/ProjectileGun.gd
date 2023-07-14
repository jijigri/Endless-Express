class_name ProjectileGun
extends Gun

@export_category("Projectile Gun settings")
@export var projectile: PackedScene
@export var projectile_speed: float = 500.0
@export var projectiles_per_shot: int = 1
@export var spread: float = 10
@export var bullet_lifetime: float = 1.0
@export var ignore_iframes: bool = true

func shoot(player_gun: Node2D, team_player: bool = true):
	
	var angle_offset: float = 0;
	var current_spread: float = spread / projectiles_per_shot;
	angle_offset -= (current_spread * (projectiles_per_shot - 1)) / 2;
	
	var id = Global.get_unique_id()
	
	for i in projectiles_per_shot:
		var spawn_point = Global.get_point_before_collision(player_gun.global_position, player_gun.spawn_point.global_position)
		var bullet_instance: Bullet = Global.spawn_object(
			projectile,
			spawn_point,
			player_gun.rotation + deg_to_rad(angle_offset + 90)
			)
		bullet_instance.initialize(damage, projectile_speed, knockback_force, bullet_lifetime)
		
		bullet_instance.gun_origin = self
		
		if ignore_iframes:
			bullet_instance.set_meta("unique_id", id)

		bullet_instance.set_team(team_player)
		
		angle_offset += current_spread
	
	super.shoot(player_gun)
