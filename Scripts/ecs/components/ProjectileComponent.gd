# ProjectileComponent.gd
extends Resource
class_name ProjectileComponent

var direction: Vector3 = Vector3.ZERO
var speed: float = 300.0
var owner_id: int = -1
var move_type: String = "linear" # "linear", "orbit", "homing"
var target_id: int = -1 # опционально для homing
