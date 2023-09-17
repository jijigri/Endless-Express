class_name TargetStateMachine
extends Enemy

@export var type: TargetEnemyData.TYPE

@export var escape_movement: EntityMovement
@export var escape_dist_squared: float = 1200.0

@export var drop_pool: TargetDropPool
@export var color_swap: ColorSwap

var spawner

var type_initialized: bool = false

func _ready() -> void:
	super._ready()
	
	if type_initialized == false:
		set_type(type)

func initialize(spawner, type: TargetEnemyData.TYPE = 1000):
	self.spawner = spawner
	if type != 1000:
		set_type(type)

func set_type(type: TargetEnemyData.TYPE) -> void:
	self.type = type
	var default_colors = color_swap.default_colors
	var replace_color = color_swap.replace_colors[self.type]
	Global.swap_color(default_colors, replace_color, $Sprite.material)
	var off_screen_marker = $OffScreenMarker
	off_screen_marker.sprite.material.set_shader_parameter("NEW_COLOR1", replace_color[0])
	off_screen_marker.sprite.material.set_shader_parameter("NEW_COLOR2", replace_color[1])
	off_screen_marker.sprite.material.set_shader_parameter("NEW_COLOR3", replace_color[2])
	type_initialized = true

func kill() -> void:
	
	drop()
	if spawner != null:
		spawner.remove_target(self.type)
	
	var instance = Global.spawn_object(ScenesPool.shockwave, global_position)
	instance.initialize(0.26, 4.0, 0.5, 0.18)
	
	super.kill()

func drop():
	if drop_pool.drops_in_enum_order.size() > type:
		var current_pool: DropPool = drop_pool.drops_in_enum_order[type]
		for item in current_pool.pool:
			var scene = item.scene
			for i in item.amount:
				Global.spawn_object(scene, global_position)

func play_hit_sound():
	var audio_data = AudioData.new(preload(AudioManager.AUDIO_PATH + "Enemies/TargetHitSound.wav"),
				global_position)
	audio_data.volume = 4.0
	AudioManager.play_in_player(
				audio_data, "hit_sound", 1, true
			)
