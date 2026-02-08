extends Resource
class_name DayTypeComponent

var type :int
func _init(_type:int = DayType.ENEMY) -> void:
	type = _type
