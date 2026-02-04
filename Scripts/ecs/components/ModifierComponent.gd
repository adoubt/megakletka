extends Resource
class_name ModifierComponent

var source_id: int =-1
var target_id: int =-1

var stat:int = Stats.PlayerStats.DAMAGE_MULT
var domain: int = Stats.Domain.PLAYER
var value: float = 0.0

func _init(_source_id: int =-1,
	_target_id: int =-1,
	
	_stat:int = Stats.PlayerStats.DAMAGE_MULT,
	_domain: int = Stats.Domain.PLAYER,
	_value: float = 0.0,

) -> void:

	target_id = _target_id
	source_id = _source_id
	stat = _stat
	domain = _domain
	value = _value
