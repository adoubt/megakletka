extends Resource
class_name JumpComponent

# CONFIG 
var jump_height: float = 7.5
var max_jumps: int = 1

# RUNTIME
var jumps_left: int = 1

func _init( _max_jumps: int = 1,_jump_height: float = 5.0,) -> void:
	jump_height = _jump_height
	max_jumps = _max_jumps
