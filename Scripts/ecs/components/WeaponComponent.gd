extends Resource
class_name WeaponComponent



var name: String = "nonamed weapon"
var cd: float = 1.0
var cd_timer: float = 0.0
var owner_id: int = -1
var target: bool = false

func _init(_name:String = "nonamed weapon", _cd: float = 1.5,_owner_id: int = -1, _target: bool = false):
	name = _name
	cd = _cd
	owner_id = _owner_id
	target = _target
