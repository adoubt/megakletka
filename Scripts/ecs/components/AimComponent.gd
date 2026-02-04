extends Resource
class_name AimComponent

var position: Vector3 
var has_position: bool = false
func _init(_target_position: Vector3=Vector3.ZERO, _has_position: bool = false ) -> void:
	
	position = _target_position
	has_position = _has_position
