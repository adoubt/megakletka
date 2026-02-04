extends Resource
class_name ItemComponent


var item_name: String = ""
var owner_id: int= -1
var slot_mask: int = 0		
var slot_index: int = 0
func _init(_item_name: String = "", _owner_id:int = -1,_slot_mask: int = 0,_slot_index: int= 0) -> void:
	item_name = _item_name
	owner_id = _owner_id
	slot_mask = _slot_mask
	slot_index = _slot_index
