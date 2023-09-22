extends Node

signal score_updated(score: int)

signal arena_exited(arena: Arena)
signal arena_entered(arena: Arena)
signal arena_cleared(arena: Arena)

signal biome_changed(biome: BiomeData)

signal player_damaged(current_health: float, max_health: float, value: float)
signal player_healed(current_health: float, max_health: float, value: float)
signal player_killed()

signal ability_used(ability: AbilityBase)
signal movement_ability_used(ability: PlayerMovementAbility)

signal primary_weapon_shot()
signal secondary_weapon_shot()

signal enemy_spawned()
signal enemy_damaged(enemy: Enemy)
signal enemy_killed(enemy: Enemy)
