extends Resource
class_name StatModifierComponent

enum ModifierType { ADD, MUL }

var StatName: String = "" # например "HP", "Armor", "CritChance"
var Type: int = ModifierType.ADD
var Value: float = 0.0
