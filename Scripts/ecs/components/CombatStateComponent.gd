extends Resource
class_name CombatStateComponent

var state : int 
var phase : int = 1
var win_condition : int = CombatState.WinCondition.TIME
var spawn_interval := 0.5      
var spawn_timer := 0.0
var time_left: float = 0.0

func _init(_state: int = CombatState.INACTIVE):
	state = _state
	
