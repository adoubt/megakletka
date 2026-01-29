class_name InteractionTargetComponent
extends Resource

var action: String # "wagon", "altar", "door"
var priority: int = 0 # для выбора, если несколько рядом
var radius: float = 1.5
var interact_type: int = InteractType.PRESS
func _init(_radius: float, _priority: int, _interact_type: int = InteractType.PRESS) -> void:
	radius = _radius
	priority = _priority
	interact_type = _interact_type
