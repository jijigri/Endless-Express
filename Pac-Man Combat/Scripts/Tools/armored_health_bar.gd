extends OverheadHealthBar

@onready var armor_icon: AnimatedSprite2D = $ArmorIcon

@onready var armor_progress: ProgressBar = $ArmorProgressBar
@onready var initial_tint = tint_progress

func _ready() -> void:
	
	if health_manager is ArmoredHealthManager:
		if health_manager.is_armored == true:
			tint = back_bar.tint_progress
			tint_progress = back_bar.tint_progress
			armor_progress.visible = false
	
	if health_manager.has_signal("armor_broken"):
		health_manager.armor_broken.connect(_on_armor_broken)
	if health_manager.has_signal("armor_repaired"):
		health_manager.armor_repaired.connect(_on_armor_repaired)
		
	super._ready()

func _process(delta: float) -> void:
	if health_manager is ArmoredHealthManager == false:
		return
		
	if health_manager.is_armored == false:
		armor_progress.value = health_manager.current_armor_recharge
			

func _on_armor_broken():
	armor_icon.play("break")
	tint = initial_tint
	tint_progress = initial_tint
	
	armor_progress.max_value = health_manager.armor_recharge_time
	armor_progress.visible = true
	armor_progress.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property(armor_progress, "modulate:a", 1, 0.1)
	tween.play()


func _on_armor_repaired():
	armor_icon.play("repair")
	
	tint = back_bar.tint_progress
	tint_progress = back_bar.tint_progress
	armor_progress.modulate.a = 1
	var tween = get_tree().create_tween()
	tween.tween_property(armor_progress, "modulate:a", 0, 0.1)
	tween.play()


func _on_armor_icon_animation_finished() -> void:
	if armor_icon.animation == "repair":
		armor_icon.play("default")
