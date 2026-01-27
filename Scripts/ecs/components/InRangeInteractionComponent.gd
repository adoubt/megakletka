class_name InRangeInteractionComponent
extends Resource

var target_id: int
var interact_time :float= 1.5
var progress: float = 0.0
var is_interacting: bool = false

func _init(_target_id : int = -1):
	target_id = _target_id
