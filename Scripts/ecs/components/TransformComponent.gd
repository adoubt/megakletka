extends Resource
class_name TransformComponent

## World position of entity
var position: Vector3 = Vector3.ZERO

## Rotation in radians (optional)
var rotation: float = 0.0

## Scale factor
var scale: Vector3 = Vector3.ONE

func _init(_position  :Vector3 = Vector3.ZERO):
	position = _position 
