class_name PlayerData

var position: Vector2
var animation: String
var frame: int

func _init(pos: Vector2, animation: String, frame: int):
	self.position = pos
	self.animation = animation
	self.frame = frame
