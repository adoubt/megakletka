extends Resource
class_name InventoryComponent

var items : Array = [] # array of item entity_ids
var weapons : Array = [] # array of weapon entity_ids

func _init(_items: Array = [ ], _weapons : Array = [ ])-> void:
	items = _items
	weapons = _weapons
	
