extends Resource
class_name DamagePopupComponent

var value: float = 0.0          # Сколько урона нанесено
var damage_type: String = "physical"  # Тип урона: physical, fire, ice, etc.
var owner_id: int = -1           # Ентити, над которым показываем попап
# Новые поля для анимации
var render_priority : int = -1
var rise_offset: float = 0.0
var last_position: Vector3 = Vector3.ZERO
var drift_x: float = 0.0
func _init( _value: float = 0.0, 
		_damage_type: String = "physical",
		_owner_id: int = -1, 
		_last_position: Vector3 = Vector3.ZERO,
		_drift_x: float = 0.0):
	value = _value
	damage_type = _damage_type
	owner_id = _owner_id
	last_position = _last_position
	drift_x=_drift_x
