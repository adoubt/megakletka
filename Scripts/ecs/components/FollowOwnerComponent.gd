extends Resource
class_name FollowOwnerComponent

var owner_id: int= -1
var offset: Vector3 = Vector3.ZERO
var weight: float= 1.0
func _init(_owner_id: int= -1,_offset : Vector3 = Vector3.ZERO, _weight:float = 1.0) -> void:
	owner_id = _owner_id
	offset = _offset
	weight = _weight
