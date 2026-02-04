extends Resource
class_name PendingHealComponent

## Amount of health to apply
var amount: float = 0.0
# Инициализация
func _init(_amount: float = 0.0) -> void:
	amount = _amount
