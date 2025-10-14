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
@export var time_to_max_speed := 2.0

## Vertical ascending speed
@export var ascend_speed := 15.0

## Maximum tilt angle during movement
@export var tilt_amount := 30.0

## Smoothness of tilt movement
@export var tilt_smoothness := 5.0

## Smoothness of vertical acceleration
@export var vertical_smoothness := 2.0

## Factor for stopping(engine off); higher values make stopping smoother
@export var factor_stop : float = 2.0
## Factor for stopping (engine on); higher values make stopping smoother
@export var engine_factor_stop : float = 0.4


var blade_speed :float  = 0.9
## Blades speed
@export var target_blade_speed := 3000.0

@onready var camera_controller: Node3D = $CameraController


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




@export_group("Blades Sound")
@export var volume_local_db: float = -80.0   # от скорости винтов
@export var pitch := 0.0
@export var min_volume_db := -80.0
@export var max_pitch := 2.0
@export var min_pitch := 0.2

@export var max_volume_db := 40.0       # громкость, когда мотор включен
@export var fade_speed := 10.5          # скорость изменения громкости



var current_mass := base_mass  # масса с учётом груза

var current_tilt := Vector3.ZERO
var input_dir := Vector3.ZERO

var engine_enabled := false


##the same as Input dir
var target_velocity_y : float



var moving := false
var input_enabled: bool = false

var flashlight_on: bool = false  # флаг состояния фонаря


func _ready():
	ControllerManager.register(self)  


	_setup_flashlights()

func set_input_enabled(state: bool) -> void:
	input_enabled = state
	

		
func _input(_event):
	
	if Input.is_action_just_pressed("flashlight"):
		toggle_flashlight()


	
func _physics_process(delta):
	# --- Физика дрона всегда работает ---

	_apply_physics(delta)
	
	# --- Управление дроном только если input_enabled ---
	if input_enabled:
		
		
		
		_process_interaction(delta)
	

	_process_rotation_and_tilt(delta)
	_process_movement(delta)
	_process_rotation_blades(delta)
	_process_engine_sound(delta)

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
		
	
	# целевые скорости
	input_dir = input_dir.normalized()
	
	var target_velocity_x = input_dir.x * move_speed
	var target_velocity_z = input_dir.z * move_speed
	
	# сглаживание
	var accel_factor = delta / time_to_max_speed
	
	var _factor_stop = engine_factor_stop if ControllerManager.is_active(self) else factor_stop
	if input_dir == Vector3.ZERO:
		accel_factor = delta / _factor_stop if model.global_transform.basis.y !=Vector3.ZERO else accel_factor
	
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


func _process_interaction(_delta):
	
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


func toggle_flashlight() -> void:
	flashlight_on = !flashlight_on
	if flashlight_on:
		$AnimationPlayer.play("flashlight_on")
	else:
		$AnimationPlayer.play("flashlight_off")

func _setup_flashlights():
	flashlight.hide()
	flashlight2.hide()
	front_left_flashlight.hide()
	front_right_flashlight.hide()

func get_current_camera() -> Camera3D:
	return camera_controller.get_current_camera()

func toggle_camera() -> void:
	camera_controller.toggle_camera()
