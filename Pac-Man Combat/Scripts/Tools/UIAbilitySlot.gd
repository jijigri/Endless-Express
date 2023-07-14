extends Sprite2D

@onready var keybind: Label = $Keybind
@onready var tiled_bar: TiledBar = $TiledBar
@onready var icon: Sprite2D = $Icon
@onready var blink: Sprite2D = $Blink
@onready var shine: AnimatedSprite2D = $Shine

var is_available = false

func _ready() -> void:
	shine.visible = false
	icon.modulate.a = 0.5
	keybind.modulate = Color("282846")

func on_ability_available():
	is_available = true
	
	shine.visible = true
	shine.play("default")
	blink.visible = true
	
	blink.modulate.a = 1.0
	icon.modulate.a = 1.0
	
	keybind.modulate = Color("fabf79")
	
	var tween = create_tween()
	tween.tween_property(blink, "modulate:a", 0.0, 0.25)
	tween.tween_callback(hide_blink)
	tween.play()

func on_ability_unavailable():
	is_available = false
	
	icon.modulate.a = 0.5
	shine.visible = false
	blink.visible = false
	
	keybind.modulate = Color("282846")

func hide_blink():
	blink.visible = false
