extends AbilityBase

var effect: PackedScene = preload("res://Scenes/Effects/throw_ability_effect.tscn")

func use_ability(player_abilities: PlayerAbilities):
	Global.spawn_object(effect, Vector2(), 0, player_abilities.owner)
