extends Resource
class_name ItemComponent


var item_id: int = -1
var owner_id: int= -1
var slot_mask: int = 0		
var slot_index: int = -1
func _init(_item_id: int = -1, _owner_id:int = -1,_slot_mask: int = 0,_slot_index: int= -1) -> void:
	item_id = _item_id
	owner_id = _owner_id
	slot_mask = _slot_mask
	slot_index = _slot_index
