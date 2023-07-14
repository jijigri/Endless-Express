extends CanvasLayer

@onready var countdown_animation: AnimationPlayer = $Countdown/CountdownAnimation
@onready var player_hud: PlayerHUD = $PlayerHUD
@onready var score_counter: Label = $ScoreCounter
@onready var game_over_screen: GameOverScreen = $GameOverScreen
@onready var message_from_top_screen: MessageFromTopScreen = $MessageFromTopScreen

func _ready() -> void:
	GameEvents.score_updated.connect(_on_score_updated)

func play_countdown():
	countdown_animation.play("Countdown")

func _on_score_updated(score: int):
	score_counter.text = str(score)

func play_sliding_text(text: String, time: float = 0.8, delay: float = 0, audio: AudioData = null, direction: Vector2 = Vector2(-1, 0)) -> TitleText:
	var rect_size = get_viewport().get_visible_rect().size
	var spawn_pos = (rect_size / 2) + (direction * rect_size * -1)
	var title = Global.spawn_object(ScenesPool.title, spawn_pos, 0, self)
	title.set_title(text, time * 5)
	var end_pos = (rect_size / 2) + (direction * rect_size)
	var mid_pos = (rect_size / 2)
	
	var tween = create_tween()
	tween.tween_property(title, "position", mid_pos, time / 2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	if audio != null:
		tween.tween_callback(AudioManager.play_sound.bind(audio))
	tween.tween_property(title, "position", end_pos, time / 2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).set_delay(delay)
	tween.tween_callback(title.queue_free)
	tween.play
	
	return title

func play_smash_title(text: String, time: float = 0.2, slide_time: float = 0.1, delay: float = 0.5, audio: AudioData = null) -> TitleText:
	var rect_size = get_viewport().get_visible_rect().size
	var spawn_pos = (rect_size / 2)
	var title = Global.spawn_object(ScenesPool.title, spawn_pos, 0, self)
	title.set_title(text, time * 5)
	
	var initial_scale = title.scale
	title.scale = Vector2(5, 5)
	
	var end_pos = (rect_size / 2) + (Vector2(-1, 0) * rect_size)
	
	var tween = create_tween()
	tween.tween_property(title, "scale", initial_scale, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	if audio != null:
		tween.tween_callback(AudioManager.play_sound.bind(audio))
	tween.tween_property(title, "position", end_pos, slide_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE).set_delay(delay)
	tween.tween_callback(title.queue_free)
	tween.play
	
	return title
