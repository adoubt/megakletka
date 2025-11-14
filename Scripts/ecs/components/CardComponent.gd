extends Resource
class_name CardComponent


var card_id: String = "card_id"
var owner_id: int= -1
		
func _init(_card_id: String = "card_id", _owner_id:int = -1) -> void:
	card_id = _card_id
	owner_id = _owner_id
