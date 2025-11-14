# Один конкретный модификатор
class_name StatModifier
extends Resource

enum ModifierType { ADD, MULTIPLY, SET }

var target_stat: String           # Например: "MaxHPComponent"
var type: ModifierType = ModifierType.ADD
var value: float = 0.0
