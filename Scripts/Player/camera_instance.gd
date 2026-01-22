extends Node3D

@export var mouse_sensitivity := 0.002
@export var min_vertical := -1.4
@export var max_vertical := 1.4

var yaw := 0.0
var pitch := 0.0

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		yaw   -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, min_vertical, max_vertical)

		rotation.y = yaw
		rotation.x = pitch
