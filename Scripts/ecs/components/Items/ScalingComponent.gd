extends Resource
class_name ScalingComponent

var per: float = 1.0
var source: int = Stats.PlayerStats.DAMAGE_MULT
var domain: int = Stats.Domain.PLAYER
func _init(_per: float = 1.0, _source: int = Stats.PlayerStats.DAMAGE_MULT,_domain: int = Stats.Domain.PLAYER) -> void:
	per = _per
	source = _source
	domain = _domain 
