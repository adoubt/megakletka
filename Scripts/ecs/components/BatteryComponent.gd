extends Resource
class_name BatteryComponent

var budget: int = 100

var current_budget: int =100

func _init(_budget: int = 100) -> void:
	budget = _budget
	current_budget = _budget
	
