extends Resource
class_name CombatStateComponent

var state :int 
var phase :int = 1

var time_to_next_phase: float = 10.0

func _init(_state: int = CombatState.INACTIVE):
	state = _state
	
