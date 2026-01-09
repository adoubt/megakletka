extends Resource
class_name SlotComponent

var owner_id : int = -1
var slot_index: int = -1
var occupied: bool = false
func _init(_owner_id : int = -1, _slot_index: int = -1) -> void:
	owner_id =_owner_id
	slot_index = _slot_index
	
