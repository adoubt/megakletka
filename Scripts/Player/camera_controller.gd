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


@export_category("Effects")
@export var enable_bob : bool = true 
@export var enable_tilt : bool = true
@export var enable_fov_change : bool = true
@export_category("Effects Settings")
@export_group("Bob","bob_")
@export var bob_freq : float = 2.4
@export var bob_amp : float = 0.08
var t_bob = 0.0
@export_group("Run Tilt")
@export var run_pitch: float = 3.0 ## Degrees — наклон камеры при разгоне вперёд
@export var run_roll: float = 5.0 ## Degrees — наклон камеры при поворотах влево/вправо
@export var max_pitch: float = 10.0 ## Degrees — предел наклона вперёд/назад
@export var max_roll: float = 10.0 ## Degrees — предел бокового крена


@export_group("Others")

@export_group("FOV Change")
@export var fov_change = 1.5

var base_fov
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


func _process(delta:float):
	# --- если контроллера игрока нет или управление отключено ---
	if not player_controller or not player_controller.input_enabled:
		return
	input_rotation.x = clampf(input_rotation.x + mouse_input.y, deg_to_rad(-90), deg_to_rad(85))
	input_rotation.y += mouse_input.x
	
	# rotate camera controller (up/down)
	player_controller.camera_controller_anchor.transform.basis = Basis.from_euler(Vector3(input_rotation.x, 0.0, 0.0))
	
	# rotate player (left/right)
	player_controller.global_transform.basis = Basis.from_euler(Vector3(0.0, input_rotation.y, 0.0))
	
	global_transform = player_controller.camera_controller_anchor.get_global_transform_interpolated()
	
	mouse_input = Vector2.ZERO
	# Head bob
	if enable_bob:
	
		t_bob += delta * player_controller.velocity.length() * float(player_controller.is_on_floor())
		camera.transform.origin = _headbob(t_bob)
	#FOV
	if enable_fov_change:
		var velocity_clamped = clamp(player_controller.velocity.length(), 0.5, player_controller.sprint_speed * 2)
		var target_fov = base_fov + fov_change * velocity_clamped
		camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	#var velocity = 	player_controller.velocity 
	#var angles = rotation
	#
		#
	#if enable_tilt:
		#var forward = global_transform.basis.z
		#var right = global_transform.basis.x
#
		#var forward_dot = velocity.dot(forward)
		#var right_dot = velocity.dot(right)
#
		#var forward_tilt = clamp(forward_dot * deg_to_rad(run_pitch), deg_to_rad(-max_pitch), deg_to_rad(max_pitch))
		#var side_tilt = clamp(right_dot * deg_to_rad(run_roll), deg_to_rad(-max_roll), deg_to_rad(max_roll))
#
		## целевой наклон камеры
		#var target_angles = Vector3(forward_tilt, 0, -side_tilt)
#
		## плавно приближаем rotation к целевому
		#rotation.x = lerp(rotation.x, target_angles.x, delta * 8.0)
		#rotation.z = lerp(rotation.z, target_angles.z, delta * 8.0)


	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq / 2) * bob_amp
	return pos
