extends Resource
class_name ScaleRequestComponent

var mult_scale : float = 1.0
var debug_mode : bool = false
func _init(_mult_scale :float = 1.0, _debug_mode : bool = false) -> void:
	mult_scale = _mult_scale
	debug_mode = _debug_mode
