extends Resource
class_name POIComponent

var name :String= ""
var is_mushroom :bool = false
var mushroom_mult_size:float =1.0
func _init(_name: String ="", _is_mushroom: bool = false, _mushroom_mult_size:float =1.0) -> void:
	name = _name 
	is_mushroom = _is_mushroom
	mushroom_mult_size= _mushroom_mult_size
