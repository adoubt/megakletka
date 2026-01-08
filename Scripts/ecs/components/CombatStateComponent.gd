extends Resource
class_name CombatStateComponent

var state :int 

func _init(_state: int = CombatState.INACTIVE):
	state = _state
	
