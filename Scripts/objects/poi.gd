extends Node
@onready var hint: Node3D = $Hint
@onready var model: Node3D = $Model

func _ready()->void:
	hide_hint()
	
func show_hint() -> void:
	hint.show()

func hide_hint() -> void:
	hint.hide()

func get_subview_port() -> SubViewport:
	return $CameraPivot/SubViewport
