# res://ecs/components/MoveSpeedComponent.gd
extends StatComponent
class_name MoveSpeedComponent

func _init(_base: float = 2.0):
	base_value = _base
	final_value = _base
