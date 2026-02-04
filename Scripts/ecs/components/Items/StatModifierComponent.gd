extends Resource
class_name StatModifierComponent

var stat:int = Stats.PlayerStats.DAMAGE_MULT
var domain: int = Stats.Domain.PLAYER
var base_value: float =0.0
var final_value: float =0.0
func _init(_stat:int = Stats.PlayerStats.DAMAGE_MULT, _domain: int = Stats.Domain.PLAYER, _base_value: float = 0.0) -> void:
	stat = _stat
	base_value = _base_value
	domain = _domain
