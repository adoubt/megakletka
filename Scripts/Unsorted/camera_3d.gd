extends Camera3D

var input_enabled :bool = false

func _ready() -> void:
	ControllerManager.register(self)

func set_input_enabled(state: bool) -> void:
	input_enabled = state

func get_current_camera() -> Camera3D:
	return self
