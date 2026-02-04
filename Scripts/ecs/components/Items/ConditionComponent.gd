extends Resource
class_name ConditionComponent

var type: int = ConditionType.EQUAL
var source: int = Stats.PlayerStats.DAMAGE_MULT
var domain: int = Stats.Domain.PLAYER
var value: float = 1

func _init(_type: int = ConditionType.EQUAL, 
			_source: int = Stats.PlayerStats.DAMAGE_MULT,
			_domain: int = Stats.Domain.PLAYER, 
			_value :float =1.0) -> void:
	type = _type
	source = _source
	value = _value
	domain = _domain
