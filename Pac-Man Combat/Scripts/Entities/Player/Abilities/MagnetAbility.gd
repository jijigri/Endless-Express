extends AbilityBase

@export var magnet: PlayerMagnet
@export var magnet_radius = 80.0
@export var width_curve: Curve
@export var max_number_of_traces: int = 3

var lines = []

var running: bool = false

func use_ability(player_abilities: PlayerAbilities):
	if running:
		return
	
	running = true
	
	on_magnet_begin()
	trace_loop()

func _process(delta: float) -> void:
	if running:
		queue_redraw()

func on_magnet_begin():
	magnet.override_radius = magnet_radius

func on_magnet_end():
	magnet.override_radius = -1.0

func trace_loop() -> void:
	while running:
		trace_path_to_targets()
		await get_tree().create_timer(0.08).timeout

func trace_path_to_targets() -> void:
	for l in lines:
		l.queue_free()
	lines.clear()
	
	var targets = get_tree().get_nodes_in_group("Targets")
	
	var number_of_traces: int = 0
	
	for t in targets:
		
		var special := true
		if t.is_in_group("ResourceBubbles"):
			if number_of_traces > max_number_of_traces:
				return
			
			var dist = global_position.distance_squared_to(t.global_position)
			special = false
		
		var map = get_world_2d().navigation_map
		var path = NavigationServer2D.map_get_path(map, global_position, t.global_position, true)
	
		draw_path(path, t, special)

func draw_path(path, target, special) -> void:
	var line = Line2D.new()
	line.width = 2.0
	line.width_curve = width_curve
	
	if target.type == TargetEnemyData.TYPE.HEALTH:
		line.modulate = Color("4df15a")
	else:
		line.modulate = Color("fabf79")
	
	if special:
		line.width = 4.0
		line.modulate = Color("e12b2b")
		line.z_index = 1
	else:
		line.modulate.a = 1.0
		line.z_index = -1
	
	get_tree().root.add_child(line)
	for pos in path:
		line.add_point(pos)
	
	lines.append(line)

func _draw() -> void:
	if running: 
		DrawUtils.draw_empty_circle(self, Vector2(), magnet_radius, Color.WHITE, 72, 2.0)
