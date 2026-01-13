# ProjectileComponent.gd
extends Resource
class_name ProjectileComponent

var direction: Vector3 = Vector3.ZERO
var speed: float = 0.0
var owner_id: int = -1
var move_type: int = ProjectileMoveType.LINEAR # "linear", "orbit", "homing"
var target_id: int = -1 # опционально для homing
