extends Resource
class_name MovementComponent

var direction: Vector3 = Vector3.ZERO 


func _init( _direction : Vector3 = Vector3.ZERO,) -> void:
	direction = _direction
