extends Resource
class_name TargetRequestComponent

var radius: float = 20.0
var target_layers: int = CollisionLayers.ENEMY
var one_shot: bool = true
var target_type:int = TargetType.NORMAL
func _init(_radius: float = 20.0,_target_layers : int = CollisionLayers.ENEMY, _one_shot :bool = true, _target_type: int= TargetType.NORMAL) -> void:
	radius = _radius
	target_layers = _target_layers
	one_shot = _one_shot
	target_type = _target_type
