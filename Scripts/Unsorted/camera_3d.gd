extends Camera3D


var input_enabled :bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ControllerManager.register(self)

func set_input_enabled(state: bool) -> void:
	input_enabled = state
# Called every frame. 'delta' is the elapsed time since the previous frame.

	
func get_current_camera() -> Camera3D:
	return self
