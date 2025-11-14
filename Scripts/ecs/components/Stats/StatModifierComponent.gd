extends Resource
class_name StatModifierComponent


enum ModifierType { ADD, MULTIPLY }

var target_stat: String     # Имя компонента, например "MaxHPComponent"
var type: ModifierType
var value: float

func _init(_target_stat:String, _type: ModifierType, _value: float) -> void:
	target_stat = _target_stat
	type = _type
	value = _value
