extends Resource
class_name PendingDamageComponent

## Amount of damage to apply
var amount: float = 10.0

## ID of entity that caused the damage
var source_id: int = -1

## Target entity ID (optional)
var target_id: int = -1

# Инициализация
func _init(_amount: float = 10.0, _source_id: int = -1, _target_id: int = -1) -> void:
	amount = _amount
	source_id = _source_id
	target_id = _target_id
