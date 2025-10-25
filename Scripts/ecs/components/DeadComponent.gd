extends Resource
class_name DeadComponent

## Time until corpse disappears
var decay_time: float = 0.1


func _init(_decay_time : float = 0.1) -> void:
	decay_time = _decay_time
