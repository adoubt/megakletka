extends Resource
class_name HPChangeRequestComponent

var value: float = 0.0

var source_id: int = -1

func _init(_value: float = 0.0, _source_id: int = -1) -> void:
	value = _value
	source_id = _source_id
