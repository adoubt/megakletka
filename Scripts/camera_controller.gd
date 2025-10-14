class_name CameraController
extends Node3D

var player_controller: PlayerController
var input_rotation: Vector3
var mouse_input: Vector2
var mouse_sensitivity: float = 0.004
@onready var camera: Camera3D = $Camera3D

var use_interpolation: bool = false
var circle_strafe: bool = true
#bob variables
@export_group("Bob","bob_") 
@export var bob_freq : float = 2.4
@export var bob_amp : float = 0.08
var t_bob = 0.0
@export_group("Others")
@export var fov_change = 1.5
@onready var base_fov
func _ready() -> void:
	base_fov = camera.fov
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player_controller = get_parent()

func _unhandled_input(event: InputEvent) -> void:
	if not player_controller.input_enabled:
		return
	if event is InputEventMouseMotion:
		mouse_input.x += -event.screen_relative.x * mouse_sensitivity
		mouse_input.y += -event.screen_relative.y * mouse_sensitivity

#func _process(_delta: float) -> void:
	#input_rotation.x = clampf(input_rotation.x + mouse_input.y, deg_to_rad(-90), deg_to_rad(85))
	#input_rotation.y += mouse_input.x
	#
	## rotate camera controller (up/down)
	#player_controller.camera_controller_anchor.transform.basis = Basis.from_euler(Vector3(input_rotation.x, 0.0, 0.0))
	#
	## rotate player (left/right)
	#player_controller.global_transform.basis = Basis.from_euler(Vector3(0.0, input_rotation.y, 0.0))
	#
	#global_transform = player_controller.camera_controller_anchor.get_global_transform_interpolated()
	#
	#mouse_input = Vector2.ZERO
	
func _physics_process(delta: float) -> void:
	input_rotation.x = clampf(input_rotation.x + mouse_input.y, deg_to_rad(-90), deg_to_rad(85))
	input_rotation.y += mouse_input.x
	
	# rotate camera controller (up/down)
	player_controller.camera_controller_anchor.transform.basis = Basis.from_euler(Vector3(input_rotation.x, 0.0, 0.0))
	
	# rotate player (left/right)
	player_controller.global_transform.basis = Basis.from_euler(Vector3(0.0, input_rotation.y, 0.0))
	
	global_transform = player_controller.camera_controller_anchor.get_global_transform_interpolated()
	
	mouse_input = Vector2.ZERO
	# Head bob
	t_bob += delta * player_controller.velocity.length() * float(player_controller.is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(player_controller.velocity.length(), 0.5, player_controller.sprint_speed * 2)
	var target_fov = base_fov + fov_change * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq / 2) * bob_amp
	return pos
