class_name InteractionTargetComponent
extends Resource

var action: String # "wagon", "altar", "door"
var priority: int = 0 # для выбора, если несколько рядом
var radius: float = 1.5

func _init(_radius: float, _priority: int) -> void:
	radius = _radius
	priority = _priority
