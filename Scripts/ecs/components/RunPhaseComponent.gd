extends Resource
class_name RunPhaseComponent


enum Phase {
	INIT,
	DIFFICULTY_READY,
	FLOORS_CREATED,
	POI_READY,
	RUNNING
}
var value : Phase

func _init(_phase: Phase = Phase.INIT) -> void:
	value = _phase
