extends Resource
class_name TitleComponent

var title: String
var description: String

func _init(_title: String = "Title", _description: String= "Description") -> void:
	title = _title
	description = _description
