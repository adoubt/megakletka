class_name TriggerEventComponent
var event_id: int = AbilityTriggers.Events.USED
var owner_id: int =-1
var payload: Dictionary = {}
func _init(_event_id: int = AbilityTriggers.Events.USED, _owner_id:int =-1) -> void:
	event_id = _event_id
	owner_id = _owner_id
