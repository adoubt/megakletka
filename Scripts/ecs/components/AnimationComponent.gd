extends Resource
class_name AnimationComponent

var type: int = AnimationType.FLOAT
var amplitude : float = 0.05
var speed : float = 0.5
var phase: float 
var base_y: float 
var time: float = 0.0
var was_highlighted := false
var started: bool = false
var smooth_speed : float = 8.0
func _init(_type: int = AnimationType.FLOAT) -> void:
	type = _type
