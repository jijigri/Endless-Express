extends CanvasLayer

@onready var number_of_enemies_label = $Control/NumberOfEnemiesLabel
@onready var enemies_label = $Control/EnemiesLabel
@onready var number_of_ghosts = $Control/NumberOfGhosts

@onready var arena_manager: ArenaManager = get_tree().get_first_node_in_group("ArenaManager")

func _ready() -> void:
	GameEvents.enemy_killed.connect(_on_enemy_killed)
	GameEvents.enemy_spawned.connect(refresh_enemies)


func _process(delta):
	visible = Global.debug_mode

func _on_enemy_killed(enemy: Enemy):
	refresh_enemies()
	

func refresh_enemies():
	if visible == false:
		return
	
	var number_of_enemies = arena_manager.current_arena.chaser_spawner.current_number_of_enemies
	var enemies = get_tree().get_nodes_in_group("Chasers")
	
	number_of_enemies_label.text = "Number of enemies: " + str(number_of_enemies)
	
	var enemies_text = ""
	
	for i in enemies.size():
		var enemy = enemies[i]
		enemies_text += str(i) + ": " + enemy.name + "\n"
	
	enemies_label.text = enemies_text
	
	number_of_ghosts.text = "Number of ghosts: " + str(PlayerDataQueue.current_number_of_ghosts)
