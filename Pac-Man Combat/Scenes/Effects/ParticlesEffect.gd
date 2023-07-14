extends DestroyAfterTime

func _ready() -> void:
	self.restart()
	for i in get_children():
		i.restart()
