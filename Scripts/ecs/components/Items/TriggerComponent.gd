extends Resource
class_name TriggerComponent

var event: int = AbilityTriggers.Events.MUSHROOM_EATED
var action: int = AbilityTriggers.Actions.GAIN_VALUE
var value: float = 0.0
func _init(_event:int = AbilityTriggers.Events.MUSHROOM_EATED,
			_action: int = AbilityTriggers.Actions.GAIN_VALUE,
			_value: float = 0.0)-> void: 
			
	event =_event
	action = _action
	value = _value
