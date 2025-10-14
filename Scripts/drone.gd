extends CharacterBody3D




@export_group("Drone")

## Mass of the empty drone
@export var base_mass := 1.0

## Maximum falling speed
@export var max_fall_speed: float = 40.0

## Gravity (m/s²)
@export var gravity := -40

## Horizontal movement speed
@export var move_speed := 40.0

## Time to reach maximum horizontal speed
@export var time_to_max_speed := 1.0

## Vertical ascending speed
@export var ascend_speed := 15.0

## Rotation speed in degrees per second
@export var rotation_speed := 360.0

## Maximum tilt angle during movement
@export var tilt_amount := 30.0

## Smoothness of tilt movement
@export var tilt_smoothness := 5.0

## Smoothness of vertical acceleration
@export var vertical_smoothness := 2.0

## Factor for stopping; higher values make stopping smoother
@export var factor_stop := 0.4

@export var drone_new_control :bool = true

## Enable flight assistant (Not emplimented yet).
@export var flight_assistant: bool = false
var blade_speed :float  = 0.9
## Blades speed
@export var target_blade_speed := 3000.0
@onready var ui_manager = UIManager

@onready var camera_pivot = $CameraPivot
@onready var camera1 := $CameraPivot/Camera3D
@onready var ray_cast_forward: RayCast3D = $Model/RayCastForward
@onready var ray_cast_backward: RayCast3D = $Model/RayCastBackward
@onready var ray_cast_up: RayCast3D = $Model/RayCastUp
@onready var ray_cast_down: RayCast3D = $Model/RayCastDown
@onready var ray_cast_camera: RayCast3D = $CameraPivot/RayCastCamera

@onready var camera_pivot2 = $CameraPivot2

@onready var camera2 := $CameraPivot2/Camera3D2

var control_yaw: float = 0.0       # мгновенный отклик мыши
var model_lag_speed: float = 5.0   # скорость плавного поворота модели (настройка)
@onready var label_status := $"../HUDManager/HUD/GrabLabel"
@onready var model = $Model
#@onready var grab_area := $Area3D

@onready var blade1 := $Model/Blades/Blade1pivot
@onready var blade2 := $Model/Blades/Blade2pivot
@onready var blade3 := $Model/Blades/Blade3pivot
@onready var blade4 := $Model/Blades/Blade4pivot
@onready var blade_sound := $BladeSound
@onready var flashlight: SpotLight3D = $Model/lights/SpotLight3D
@onready var flashlight2: SpotLight3D = $Model/lights/SpotLight3D2
@onready var front_left_flashlight:= $Model/lights/front/On/LeftFlashlight
@onready var front_right_flashlight:= $Model/lights/front/On/RightFlashlight


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
var base_camera1_pos :Vector3
var base_fov1 : float
var far_fov1 : float
var base_fov2 : float
var far_fov2 : float
var base_distance : float    # нормальная дистанция (настроится в _ready)
var base_height : float  # нормальная высота (настроится в _ready)

@export_group("Blades Sound")
@export var volume_local_db: float = -80.0   # от скорости винтов
@export var pitch := 0.0
@export var default_pitch := 0.0
@export var min_volume_db := -80.0
@export var max_pitch := 2.0
@export var min_pitch := 0.2

@export var max_volume_db := 40.0       # громкость, когда мотор включен
@export var fade_speed := 10.5          # скорость изменения громкости



var current_mass := base_mass  # масса с учётом груза
var joint: PinJoint3D = null

var current_tilt := Vector3.ZERO
var input_dir := Vector3.ZERO
var grabbed_box: RigidBody3D = null
var is_grabbing := false
var grab_offset := Vector3(0, -0.22, 0)
var engine_enabled := false
var mouse_joystick_active := true
var mouse_delta := Vector2.ZERO
##the same as Input dir
var target_velocity_y : float



var moving := false
var input_enabled: bool = false

var flashlight_on: bool = false  # флаг состояния фонаря


func _ready():
	ControllerManager.register(self)  
	_setup_ray_casts()
	_setup_camera()
	_setup_flashlights()

func set_input_enabled(state: bool) -> void:
	input_enabled = state
	
func toggle_camera() -> void:
	if current_camera_index == 1:
		camera2.make_current()
		current_camera_index = 2
	else:
		camera1.make_current()
		current_camera_index = 1
		
func get_current_camera() -> Camera3D:
	return camera1 if current_camera_index == 1 else camera2
		
func _input(event):
	if not input_enabled:
		return
	elif event is InputEventMouseMotion and mouse_joystick_active:
		mouse_delta = event.relative
	if Input.is_action_just_pressed("flashlight"):
		toggle_flashlight()

func _rotate_camera(direction: int):
	var new_rot = camera2.rotation.x + deg_to_rad(direction * rotation_speed * get_process_delta_time())
	new_rot = clamp(new_rot, deg_to_rad(-90), deg_to_rad(45))
	camera2.rotation.x = new_rot
	
func _physics_process(delta):
	# --- Физика дрона всегда работает ---

	_apply_physics(delta)
	
	# --- Управление дроном только если input_enabled ---
	if input_enabled:
		
		
		_process_mouse_camera(delta)
		_process_interaction(delta)
	
		_apply_shaders()
	_process_rotation_and_tilt(delta)
	_process_movement(delta)
	_process_rotation_blades(delta)
	_process_engine_sound(delta)
	# --- тут обрабатываем камеру ---
	_update_camera_follow(delta)
func _apply_physics(delta):
	
	if not engine_enabled:
		velocity.y +=gravity * delta
		velocity.y = max(velocity.y, -max_fall_speed)
		
	move_and_slide()
	

func _process_movement(delta):
	moving = false
	
	input_dir = Vector3.ZERO
	target_velocity_y = 0.0	
	if input_enabled:
		if Input.is_action_pressed("drone_forward"):
			input_dir -= model.global_transform.basis.z
			engine_enabled = true
			moving = true
		if Input.is_action_pressed("drone_back"):
			input_dir += model.global_transform.basis.z
			engine_enabled = true
			moving = true
		if Input.is_action_pressed("drone_left"):
			input_dir -= model.global_transform.basis.x
			engine_enabled = true
			moving = true
		if Input.is_action_pressed("drone_right"):
			input_dir += model.global_transform.basis.x
			engine_enabled = true
			moving = true
		
		if Input.is_action_pressed("drone_up"):
			target_velocity_y = +ascend_speed
			engine_enabled = true
			moving = true
		if Input.is_action_pressed("drone_down"):
			target_velocity_y = -ascend_speed
			engine_enabled = true
			moving = true
		if Input.is_action_pressed("rotate_camera_up"):
			_rotate_camera(-1)
		if Input.is_action_pressed("rotate_camera_down"):
			_rotate_camera(1)	
	
	# целевые скорости
	input_dir = input_dir.normalized()
	
	var target_velocity_x = input_dir.x * move_speed
	var target_velocity_z = input_dir.z * move_speed
	
	# сглаживание
	var accel_factor = delta / time_to_max_speed
	
	
	var _factor_stop = factor_stop if ControllerManager.is_active(self) else 2.0
	if input_dir == Vector3.ZERO:
		accel_factor = delta / _factor_stop if model.global_transform.basis.y !=Vector3.ZERO else accel_factor
	#var accel_factor_y =  delta / factor_stop if model.global_transform.basis.y !=Vector3.ZERO else accel_factor
	
	velocity.x = lerp(velocity.x, target_velocity_x, accel_factor)
	velocity.y = lerp(velocity.y, target_velocity_y, vertical_smoothness *delta)
	velocity.z = lerp(velocity.z, target_velocity_z, accel_factor)	
	
	
	
func _process_rotation_and_tilt(delta):

	# наклон при движении
	var local_input = model.global_transform.basis.inverse() * input_dir
	var target_tilt_x = local_input.z * tilt_amount
	var target_tilt_z = -local_input.x * tilt_amount
	current_tilt.x = lerp(current_tilt.x, target_tilt_x, delta * tilt_smoothness)
	current_tilt.z = lerp(current_tilt.z, target_tilt_z, delta * tilt_smoothness)
	model.rotation_degrees.x = current_tilt.x
	model.rotation_degrees.z = current_tilt.z


var control_pitch : float= 0.0
var pitch_limit : float= deg_to_rad(30)
var pitch_return_speed : = 1.5  # скорость возврата
var idle_time : float= 0.0
var idle_delay : float= 1.3  # через сколько секунд начинать выравнивать	

func _process_mouse_camera(delta):
	if !SettingsManager.values["drone_new_control"]: 
		if mouse_joystick_active:
			rotate_object_local(Vector3.UP, -deg_to_rad(mouse_delta.x * mouse_sensitivity))
			mouse_delta = Vector2.ZERO
		else:
			rotation_degrees.x = lerp(rotation_degrees.x, default_pitch, delta * 2.0)
		
		
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
		
		if engine_enabled:
		# --- применяем вращение ---
			camera_pivot.rotation = Vector3(control_pitch, control_yaw, 0)
		
			# --- визуальная модель дрона догоняет yaw ---
		var target_yaw = control_yaw
	
	
		model.rotation.y = lerp_angle(model.rotation.y, target_yaw, delta * model_lag_speed)
	

func _process_interaction(delta):
	
	if Input.is_action_just_pressed("drone_engine_toggle"):
		engine_enabled = not engine_enabled

func _process_rotation_blades(delta):
	# --- вращение лопастей ---
	
	var _target_blade_speed = target_blade_speed if engine_enabled else 0.0
	blade_speed = lerp(blade_speed, _target_blade_speed, delta * 5.0)
	var rotation_amount = deg_to_rad(blade_speed * delta)
	blade1.rotate_y(rotation_amount)
	blade2.rotate_y(rotation_amount)
	blade3.rotate_y(rotation_amount)
	blade4.rotate_y(rotation_amount)

	
func _process_engine_sound(delta: float) -> void:
	var speed = velocity.length()
	var max_speed = 35.0
	var min_speed = 0.0

	# --- запуск звука ---
	if engine_enabled and not blade_sound.playing:
		blade_sound.play()

	if engine_enabled:
		# громкость и питч зависят от скорости
		var intensity = clamp((speed - min_speed) / (max_speed - min_speed), 0.2, 1.0)

		var target_local_db = lerp(min_volume_db, max_volume_db, intensity)
		blade_sound.volume_local_db = lerp(blade_sound.volume_local_db, target_local_db, delta * fade_speed)

		var target_pitch = lerp(min_pitch, max_pitch, intensity)
		blade_sound.pitch_scale = lerp(blade_sound.pitch_scale, target_pitch, delta * fade_speed)
	else:
		# плавно уводим громкость и питч вниз
		blade_sound.volume_local_db = lerp(blade_sound.volume_local_db, min_volume_db, delta * fade_speed * 0.5)
		blade_sound.pitch_scale = lerp(blade_sound.pitch_scale, min_pitch, delta * fade_speed * 0.5)

		# стопаем звук только когда он реально затух
		if blade_sound.volume_local_db <= min_volume_db + 1 and blade_sound.playing:
			blade_sound.stop()

func _update_camera_follow(delta):
	var use_fov_effect = SettingsManager.get_value("use_fov_effect")
	var horiz_speed = Vector3(velocity.x, velocity.y, velocity.z).length()
	var t = clamp(horiz_speed / move_speed, 0.0, 1.0)
	# --- лаг поворота (как было) ---
	if current_camera_index == 2:
		camera_pivot2.rotation.y = model.rotation.y
		if use_fov_effect:
			# плавно меняем FOV

			var target_fov = lerp(base_fov2, far_fov2, t)
			camera2.fov = lerp(camera2.fov, target_fov, delta * zoom_speed)
			
	else:
		var target_yaw = model.rotation.y
		camera_yaw = lerp_angle(camera_yaw, target_yaw, delta * camera_lag)
		camera_pivot.rotation.y = camera_yaw

		# --- базовое расстояние до камеры ---
		var target_dist: float
		if use_fov_effect:
			# плавно меняем FOV
			
			var target_fov = lerp(base_fov1, far_fov1, t)
			camera1.fov = lerp(camera1.fov, target_fov, delta * zoom_speed)
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
		
			
		ray_cast_camera.target_position = camera1.position
		if ray_cast_camera.is_colliding():
			var hit_pos = ray_cast_camera.get_collision_point()
			var local_hit = camera_pivot.to_local(hit_pos)
			var dist = max(0.3, abs(local_hit.z))
			target_dist = lerp(target_dist, min(target_dist, dist),0.5)
		
		if dinamic_v_offset:
			if target_velocity_y != 0.0:
				target_y = lerp(target_y, - target_velocity_y * 0.1, 0.1)
			
		
		# --- интерполяция текущей позиции камеры ---
		var cur_z = lerp(camera1.position.z, target_dist, delta * zoom_speed)
		var cur_y = lerp(camera1.position.y, target_y, delta * zoom_speed)

		var pos = camera1.position
		pos.z = cur_z
		pos.y = cur_y
		camera1.position = pos



		
		
func _apply_shaders():
	var speed = velocity.length()
	var shader_param = 0.0

	# Минимальная скорость для появления линий
	var min_speed = 15
	# Максимальная скорость, на которой линии полностью видны
	var max_speed = 35

	if speed > min_speed:
		# Линейная интерполяция прозрачности от min_speed до max_speed
		shader_param = clamp((speed - min_speed) / (max_speed - min_speed), 0.0, 0.4)
	
	$"../HUDManager/SpeedLines".material.set_shader_parameter("line_density", shader_param)

func toggle_flashlight() -> void:
	flashlight_on = !flashlight_on
	if flashlight_on:
		$AnimationPlayer.play("flashlight_on")
	else:
		$AnimationPlayer.play("flashlight_off")


func _setup_ray_casts():
	var rays = [ray_cast_forward, ray_cast_backward, ray_cast_up, ray_cast_down, ray_cast_camera]
	for ray in rays:
		ray.add_exception(self)
		
func _setup_camera():
	camera_yaw = model.rotation.y
	camera_pivot.rotation.y = camera_yaw
	base_distance = camera1.position.z
	base_height = camera1.position.y
	base_camera1_pos = camera1.position
	base_fov1 = camera1.fov
	far_fov1 = base_fov1 + affect_fov
	base_fov2 = camera2.fov
	far_fov2 = base_fov2 + affect_fov

func _setup_flashlights():
	flashlight.hide()
	flashlight2.hide()
	front_left_flashlight.hide()
	front_right_flashlight.hide()

	
