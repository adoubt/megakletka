extends Resource
class_name CameraComponent

var owner_id: int = -1
var yaw: float = 3.0
var pitch: float = -20.0
var forward: Vector3 = Vector3.FORWARD
var forward_3d: Vector3 = Vector3.FORWARD
var right: Vector3 = Vector3.RIGHT
var distance: float = -3.0
var offset: Vector3 = Vector3(0, 1.5, 0)
var camera_instance: Camera3D = null
var smoothing: float = 5.0
var sensativity : float=  1.0
var controller_sensativity:float = 3.2
var inverted_horisontal_axis:bool
var inverted_vertical_axis:bool
var hold_crouch: bool
var hold_aim: bool


func _init(_owner_id: int = -1,) -> void:
	owner_id = _owner_id
