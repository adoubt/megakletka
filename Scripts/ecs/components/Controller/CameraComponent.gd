extends Resource
class_name CameraComponent
enum Mode {
	FOLLOW,
	FOCUS,
	BLEND_TO_FOLLOW,
	LOCKED_FOLLOW,
	
}
var owner_id: int = -1
var yaw: float = 3.0
var pitch: float = -1.0
var forward: Vector3 = Vector3.FORWARD
var forward_3d: Vector3 = Vector3.FORWARD
var right: Vector3 = Vector3.RIGHT
var distance: float = -3.3
var offset: Vector3 = Vector3(0, 1.3, 0)
var camera_instance: Camera3D = null
var smoothing: float = 5.0
var sensativity : float=  1.0
var controller_sensativity:float = 3.2
var inverted_horisontal_axis:bool
var inverted_vertical_axis:bool
var hold_crouch: bool
var hold_aim: bool
var base_fov: float = 90
var mode: int = Mode.FOLLOW
var focus_from_pos:Vector3
var focus_target: Vector3
var return_start_pos:Vector3
var return_start_rot: Basis
var transition_elapsed: float
var transition_time: float = 0.6

func _init(_owner_id: int = -1,) -> void:
	owner_id = _owner_id
