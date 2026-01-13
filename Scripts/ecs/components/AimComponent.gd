extends Resource
class_name AimComponent

var has_position: bool
var position: Vector3 
func _init(_target_position: Vector3=Vector3.ZERO,_has_position:bool =false) -> void:
	has_position =_has_position
	position = _target_position
