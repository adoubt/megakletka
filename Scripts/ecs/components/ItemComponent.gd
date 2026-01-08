extends Resource
class_name ItemComponent


var item_name: String = ""
var owner_id: int= -1
		
func _init(_item_name: String = "", _owner_id:int = -1) -> void:
	item_name = _item_name
	owner_id = _owner_id
