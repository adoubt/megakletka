extends Node3D

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera: Camera3D = $Camera3D
@onready var player_controller: CharacterBody3D = $".."


@export var mouse_sensitivity: float = 0.005
@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var min_vertical_angle: float = -PI / 2
@export_range(0.0, 90.0, 0.1, "radians_as_degrees") var max_vertical_angle: float = PI / 4
@export var min_zoom_in : float = 0.5

@export var max_zoom_in : float = 15.0
var current_camera : Camera3D


func _ready() -> void:
	pass
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Горизонтальное вращение (вокруг игрока)
		rotation.y -= event.relative.x * mouse_sensitivity
		rotation.y = wrapf(rotation.y, 0.0, TAU)

		# Вертикальный наклон (через spring arm)
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation.x = clamp(rotation.x, min_vertical_angle, max_vertical_angle)

	# Изменение дистанции камеры (зум колесиком)
	if event.is_action_pressed("wheel_up"):
		spring_arm.spring_length = clamp(spring_arm.spring_length - 1.0, min_zoom_in, max_zoom_in)

	if event.is_action_pressed("wheel_down"):
		spring_arm.spring_length = clamp(spring_arm.spring_length + 1.0, min_zoom_in, max_zoom_in)


	
