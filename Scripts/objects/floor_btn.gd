
extends Usable

@onready var label_3d: Label3D = $Label3D

@export var floor_number: int

func _ready():
	_set_index(floor_number)
	
func _set_index(value: int):
	label_3d.text = str(value)
	prompt_message = "Floor " + str(value)

	
func _on_interacted(body : Variant) -> void:
	var elevator_behavior = get_tree().get_root().find_child("ElevatorBehavior", true, false) 
	elevator_behavior.request_floor(floor_number)
	
