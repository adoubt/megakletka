extends Resource
class_name DayComponent

var floor: int = 0
var ante: int
var type: int
var column: int  
var completed: bool = false     
func _init(_floor: int = -1,_ante: int = -1, _type: int= DayType.ENEMY, _column:int =0 ) -> void:
	floor = _floor
	ante = _ante
	type =_type
	column = _column
