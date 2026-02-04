extends Resource
class_name ItemAbilityComponent

var owner_id: int
var name: String = "Ability"

func _init(_owner_id:int =-1,_name:String= name) -> void:
	owner_id = _owner_id
	name = _name
	
