extends AbilityBase

@export var projectile: PackedScene
@export var gun: PlayerGun

var throw_sound = preload("res://Audio/SoundEffects/Abilities/SwapBladeThrow.wav")

func use_ability(player_abilities: PlayerAbilities):
	var _rotation = gun.anchor.global_rotation
	var bullet_instance = Global.spawn_object(
				projectile,
				gun.spawn_point.global_position,
				_rotation
				)
	
	bullet_instance.player = gun.player
	
	var audio_data = AudioData.new(throw_sound, global_position)
	AudioManager.play_sound(audio_data)
