extends Resource
class_name PendingDamageComponent

## Amount of damage to apply
var amount: float = 10.0

## ID of entity that caused the damage
var source_id: int = -1

## Target entity ID (optional)
var target_id: int = -1
var execute_chance: float = 0.0
var pierce: bool = false
# Инициализация
func _init(_amount: float = 10.0, _source_id: int = -1, _target_id: int = -1,
			_execute_chance: float = 0.0, _pierce: bool = false) -> void:
	amount = _amount
	source_id = _source_id
	target_id = _target_id
	execute_chance = _execute_chance
	pierce = _pierce
	
