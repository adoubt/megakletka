extends Resource
class_name StatModifierComponent

enum ModifierType { ADD, MUL, SET}

var stat_name: String = "" # например "HP", "Armor", "CritChance"
var type: int = ModifierType.ADD
var value: float = 0.0
