extends Resource
class_name RespawnableComponent

var death_frame: int = -1

func _init(_death_frame: int = -1) -> void:
	death_frame = _death_frame
