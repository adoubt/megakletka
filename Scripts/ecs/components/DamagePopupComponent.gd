extends Resource
class_name DamagePopupComponent

var value: float = 0.0          # Сколько урона нанесено
var damage_type: String = "physical"  # Тип урона: physical, fire, ice, etc.
var owner_id: int = -1           # Ентити, над которым показываем попап
# Новые поля для анимации
var initial_position: Vector3 = Vector3.ZERO  # Позиция спавна
var rise_offset: float = 0.0
var last_position: Vector3 = Vector3.ZERO
func _init( _value: float = 0.0, _damage_type: String = "physical",_owner_id: int = -1, _last_position: Vector3 = Vector3.ZERO):
	value = _value
	damage_type = _damage_type
	owner_id = _owner_id
	last_position = _last_position
