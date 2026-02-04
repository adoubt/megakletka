extends Resource
class_name PendingDamageComponent

## Amount of damage to apply
var amount: float = 10.0

## ID of entity that caused the damage
var source_id: int = -1


var execute_chance: float = 0.0

# Инициализация
func _init(_amount: float = 10.0, _source_id: int = -1,
			_execute_chance: float = 0.0, ) -> void:
	amount = _amount
	source_id = _source_id
	
	execute_chance = _execute_chance
	
	
