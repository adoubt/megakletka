extends Resource
class_name LevelUpOfferComponent

var owner_id: int = -1
var choices: Array = []        # список апгрейдов
var chosen_index: int = -1     # индекс выбранного (по умолчанию -1)

func _init(_owner_id: int = -1, _choices: Array = []) -> void:
	owner_id = _owner_id
	choices = _choices
