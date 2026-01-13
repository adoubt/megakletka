extends Resource
class_name MovementComponent

var direction: Vector3 = Vector3.ZERO 
var speed: float  = 0.0

func _init( _speed : float = 0.0,_direction : Vector3 = Vector3.ZERO,) -> void:
	direction = _direction
	speed = _speed
