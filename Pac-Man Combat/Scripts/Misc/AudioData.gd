class_name AudioData

var stream: AudioStream
var position: Vector2
var volume: float = 0 : set = set_volume
var pitch: float = 1 : set = set_pitch
var max_distance: float = 4000 : set = set_distance
var attenuation: float = 1.0

func _init(_stream: AudioStream, _position = Vector2.ZERO, _volume: float = 0, _pitch: float = 1):
	stream = _stream
	position = _position
	volume = _volume
	pitch = _pitch

func set_volume(new_volume):
	volume = clamp(new_volume, -80.0, 24.0)

func set_pitch(new_pitch):
	pitch = clamp(new_pitch, 0.01, 4.0)

func set_distance(new_distance):
	max_distance = clamp(new_distance, 1, 10000)
