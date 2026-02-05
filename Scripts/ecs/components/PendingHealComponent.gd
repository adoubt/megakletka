extends Resource
class_name PendingHealComponent

## Amount of health to apply
var amount: float = 0.0
var source_id: int = -1
# Инициализация
func _init(_amount: float = 0.0,_source_id: int = -1) -> void:
	amount = _amount
	source_id = _source_id
