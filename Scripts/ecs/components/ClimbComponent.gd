extends Resource
class_name ClimbComponent

var climb_time_left: float = 0.1

func _init(_climb_time_left: float = 0.5 ) -> void:
	climb_time_left = _climb_time_left
