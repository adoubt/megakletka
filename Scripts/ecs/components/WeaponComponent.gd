extends Resource
class_name WeaponComponent



var name: String = "nonamed weapon"
var cd: float = 1.0
var cd_timer: float = 0.0
var owner_id: int = -1
var target: int = 0
var proj_scene : String =""

func _init(_name:String = "nonamed weapon", _cd: float = 1.5,_owner_id: int = -1, _target: int = 0,_proj_scene: String=""):
	name = _name
	cd = _cd
	owner_id = _owner_id
	target = _target
	proj_scene =_proj_scene
