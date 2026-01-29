extends Resource
class_name POIComponent

var name :String= ""
var is_mushroom :bool = false
func _init(_name: String ="", _is_mushroom: bool = false) -> void:
	name = _name 
	is_mushroom = _is_mushroom
