extends Resource
class_name HitVFXComponent

var owner_id: int = -1
var started: bool = false
var followed: bool = true
func _init(_owner_id: int = -1, _started: bool = false, _followed: bool = true) -> void:
	owner_id = _owner_id
	started =_started
	followed = _followed
