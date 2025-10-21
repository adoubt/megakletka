extends Node3D



@onready var drone: CharacterBody3D = $".."
@onready var model = $"../Model"
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_pivot_2: Node3D = $CameraPivot2

@onready var camera_1 := $CameraPivot/Camera3D
@onready var camera_2 := $CameraPivot2/Camera3D2

@onready var ray_cast_forward: RayCast3D = $"../Model/RayCastForward"
@onready var ray_cast_up: RayCast3D = $"../Model/RayCastUp"
@onready var ray_cast_down: RayCast3D = $"../Model/RayCastDown"
@onready var ray_cast_backward: RayCast3D = $"../Model/RayCastBackward"
@onready var ray_cast_camera: RayCast3D = $CameraPivot/RayCastCamera

@export_group("Camera")
## Camera FOV angle affect(Current FOV = Base camera FOV + affect FOV). Please set Base Camera FOV in its settings.
@export_range(0.0, 180.0, 1) var affect_fov: float = 90.0

## Dinamic Vertocal Camera Offset  
@export var dinamic_v_offset: bool = true
## How far to move camera back at maximum speed
@export var far_distance := 3.0

## Camera zoom interpolation speed
@export var zoom_speed := 5.0

## Camera selection: 1 - Third-person POV, 2 - First-person POV
@export_range(1, 2, 1) var current_camera_index: int = 1

## Horizontal rotation of the camera
@export var camera_yaw := 0.0

## Camera rotation lag (1.7 Juice)
@export var camera_lag := 1.7  

## Mouse sensitivity
@export var mouse_sensitivity := 0.2

## скорость плавного поворота модели (настройка)
@export var model_lag_speed: float = 5.0   

## Угол лимит (наверное вертикальный)
@export var pitch_limit : float= deg_to_rad(30)
## скорость возврата
@export var pitch_return_speed : = 1.5 

## через сколько секунд начинать выравнивать
@export var idle_delay : float= 1.3  

var base_camera_1_pos :Vector3
var base_fov1 : float
var far_fov1 : float
var base_fov2 : float
var far_fov2 : float
var base_distance : float    # нормальная дистанция (настроится в _ready)
var base_height : float  # нормальная высота (настроится в _ready)

var control_pitch : float= 0.0

var idle_time : float= 0.0

var control_yaw: float = 0.0       # мгновенный отклик мыши

##Я не ебу что это
@export var mouse_joystick_active := true
var mouse_delta := Vector2.ZERO

@onready var speed_lines:= $"../../HUDManager/SpeedLines"


func _ready() -> void:
	
	_setup_camera()
	_setup_ray_casts()
	_setup_fx()
	
func _input(event):
	if not drone.input_enabled:
		return
	elif event is InputEventMouseMotion:
		mouse_delta = event.relative
	
func _physics_process(delta: float) -> void:
	_update_camera_follow(delta)
	_process_mouse_camera(delta)
	_apply_shaders()
	_process_fx()
func _process_mouse_camera(delta):
	if !SettingsManager.values["drone_new_control"]: 
		drone.rotate_object_local(Vector3.UP, -deg_to_rad(mouse_delta.x * mouse_sensitivity))
		mouse_delta = Vector2.ZERO
	# --- управляем направлением мгновенно ---
	else: 
		# --- горизонтальное вращение (yaw) ---
		control_yaw += -deg_to_rad(mouse_delta.x * mouse_sensitivity)
		
		
		# если мышь двигается — сбрасываем таймер
		if mouse_delta.length() > 0.5:
			idle_time = 0.0
			# --- вертикальное вращение (pitch по орбите) ---
			control_pitch += -deg_to_rad(mouse_delta.y * mouse_sensitivity * 0.6)
			control_pitch = clamp(control_pitch, -pitch_limit, pitch_limit)

		else:
			idle_time += delta
			# если мышь не трогали дольше idle_delay — начинаем возвращать pitch
			if idle_time > idle_delay:
				control_pitch = lerp(control_pitch, 0.0, delta * pitch_return_speed)

		
		mouse_delta = Vector2.ZERO
		
		if drone.engine_enabled:
		### --- применяем вращение ---
			camera_pivot.rotation = lerp(camera_pivot.rotation, Vector3(control_pitch, control_yaw, 0),0.1)
	
		# --- визуальная модель дрона догоняет yaw ---
		var target_yaw = control_yaw
	
	
		model.rotation.y = lerp_angle(model.rotation.y, target_yaw, delta * model_lag_speed)
		
func _update_camera_follow(delta):
	var use_fov_effect = SettingsManager.get_value("use_fov_effect")
	var horiz_speed = Vector3(drone.velocity.x, drone.velocity.y, drone.velocity.z).length()
	var t = clamp(horiz_speed / drone.move_speed, 0.0, 1.0)
	# --- лаг поворота (как было) ---
	if current_camera_index == 2:
		camera_pivot_2.rotation.y = model.rotation.y
		if use_fov_effect:
			# плавно меняем FOV

			var target_fov = lerp(base_fov2, far_fov2, t)
			camera_2.fov = lerp(camera_2.fov, target_fov, delta * zoom_speed)
			
	else:
		var target_yaw = model.rotation.y
		camera_yaw = lerp_angle(camera_yaw, target_yaw, delta * camera_lag)
		camera_pivot.rotation.y = camera_yaw

		# --- базовое расстояние до камеры ---
		var target_dist: float
		if use_fov_effect:
			# плавно меняем FOV
			
			var target_fov = lerp(base_fov1, far_fov1, t)
			camera_1.fov = lerp(camera_1.fov, target_fov, delta * zoom_speed)
			target_dist = base_distance
		else:
			# отдаляем камеру по Z
			target_dist = lerp(base_distance, far_distance, t)

		 #--- проверка назад (стены за дроном) ---
		if ray_cast_backward.is_colliding():
			var hit_pos = ray_cast_backward.get_collision_point()
			var local_hit = camera_pivot.to_local(hit_pos)
			var back_dist = max(0.3, abs(local_hit.z))
			target_dist = min(target_dist, back_dist)

		# --- проверка вперёд (стена перед дроном) ---
		if ray_cast_forward.is_colliding():
			var hit_pos = ray_cast_forward.get_collision_point()
			var local_hit = camera_pivot.to_local(hit_pos)
			var front_dist = max(0.3, abs(local_hit.z))
			target_dist = min(target_dist, front_dist)
		base_height = camera_pivot.position.y
		# по умолчанию целевая высота = базовой
		var target_y = base_height

		# если потолок есть → ограничиваем сверху
		if ray_cast_up.is_colliding():
			var hit_pos = ray_cast_up.get_collision_point()
			var local_hit = camera_pivot.to_local(hit_pos)
			target_y = min(base_height, local_hit.y - 0.5)  # потолок прижимает вниз
		
		if ray_cast_down.is_colliding():
			var hit_pos = ray_cast_down.get_collision_point()
			var local_hit = camera_pivot.to_local(hit_pos)
			var height = abs(local_hit.y)

			# Чем ближе к земле — тем дальше камера
			target_dist = lerp(target_dist, target_dist + (1.0 / (height + 0.5)),0.5)
			target_y = lerp(target_y, base_height + (1.0 / (height + 0.5)), 0.5)
		
			
		ray_cast_camera.target_position = camera_1.position
		if ray_cast_camera.is_colliding():
			var hit_pos = ray_cast_camera.get_collision_point()
			var local_hit = camera_pivot.to_local(hit_pos)
			var dist = max(0.3, abs(local_hit.z))
			target_dist = lerp(target_dist, min(target_dist, dist),0.5)
		
		if dinamic_v_offset:
			if drone.target_velocity_y != 0.0:
				target_y = lerp(target_y, - drone.target_velocity_y * 0.1, 0.1)
			
		
		# --- интерполяция текущей позиции камеры ---
		var cur_z = lerp(camera_1.position.z, target_dist, delta * zoom_speed)
		var cur_y = lerp(camera_1.position.y, target_y, delta * zoom_speed)

		var pos = camera_1.position
		pos.z = cur_z
		pos.y = cur_y
		camera_1.position = pos

func toggle_camera() -> void:
	if current_camera_index == 1:
		camera_2.make_current()
		current_camera_index = 2
		control_yaw = camera_yaw
		camera_pivot_2.rotation.y = camera_yaw
	else:
		camera_1.make_current()
		current_camera_index = 1
		camera_yaw = control_yaw
		camera_pivot.rotation.y = control_yaw
		
func get_current_camera() -> Camera3D:
	return camera_1 if current_camera_index == 1 else camera_2
	
func _apply_shaders():
	var speed = drone.velocity.length()
	var shader_param = 0.0

	# Минимальная скорость для появления линий
	var min_speed = 15
	# Максимальная скорость, на которой линии полностью видны
	var max_speed = 35

	if speed > min_speed:
		# Линейная интерполяция прозрачности от min_speed до max_speed
		shader_param = clamp((speed - min_speed) / (max_speed - min_speed), 0.0, 0.4)
	if speed_lines:
		speed_lines.material.set_shader_parameter("line_density", shader_param)
	
func _setup_camera():
	camera_yaw = model.rotation.y
	camera_pivot.rotation.y = camera_yaw
	base_distance = camera_1.position.z
	base_height = camera_1.position.y
	base_camera_1_pos = camera_1.position
	base_fov1 = camera_1.fov
	far_fov1 = base_fov1 + affect_fov
	base_fov2 = camera_2.fov
	far_fov2 = base_fov2 + affect_fov

func _setup_ray_casts():
	var rays = [ray_cast_forward, ray_cast_backward, ray_cast_up, ray_cast_down, ray_cast_camera]
	for ray in rays:
		ray.add_exception(drone)

func _setup_fx() ->void:
	pass
	
func _process_fx():
	pass
