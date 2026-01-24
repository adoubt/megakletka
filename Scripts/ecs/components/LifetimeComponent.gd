extends Resource
class_name LifeTimeComponent

## Remaining lifetime in seconds
var time_left: float = 1.0


func _init(_time_left : float = 1.0) -> void:
	time_left = _time_left
