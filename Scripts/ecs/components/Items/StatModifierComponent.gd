extends Resource
class_name StatModifierComponent

var stat:int = Stats.PlayerStats.DAMAGE_MULT
var domain: int = Stats.Domain.PLAYER
var value: float = 0.0

func _init(_stat:int = Stats.PlayerStats.DAMAGE_MULT, _domain: int = Stats.Domain.PLAYER, _value: float = 0.0) -> void:
	stat = _stat
	value = _value
	domain = _domain
