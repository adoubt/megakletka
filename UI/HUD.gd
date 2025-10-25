
extends Control

const ANIMATION_DURATION:float= 0.7

@onready var fps_label: Label = $HUD/VBoxContainer/FPS

@export var min_value: float =0.0
@export var max_value: float = 100.0
@export var value: float = 100.0:
	set = set_value
@onready var progress_shader: ShaderMaterial 
@onready var current_hp_texture: ColorRect = $HUD/VBoxContainer/Control/LeftPanel/Control2/HP/Control/MarginContainer/Control/CurrentHp
@onready var current_hp_label: Label = $HUD/VBoxContainer/Control/LeftPanel/Control2/HP/Control/MarginContainer/Control/CurrentHPLabel

func _ready() ->void:
	progress_shader = current_hp_texture.material
	update_texture(0)

func set_value(new_value:float):
	var diff = new_value - value 
	value  = clampf(new_value,min_value,max_value)
	update_texture(sign(diff))
	update_current_hp(value)
var _tween: Tween
var _time_passed := 0.0
var _refresh_interval := 0.5  # обновляем FPS раз в 0.5 сек

	# FPS обновится на первом цикле _process
func update_current_hp(_value:float):
	current_hp_label.text= str(int(_value)) + "/" + str(int(max_value))
func update_texture(direction:int):
	var progress = value / (max_value - min_value)
	if direction < 0:
		get_tween().tween_property(progress_shader,"shader_parameter/progress_tail", progress, ANIMATION_DURATION)
		progress_shader.set_shader_parameter("progress", progress)
	elif direction >0:
		get_tween().tween_property(progress_shader,"shader_parameter/progress", progress, ANIMATION_DURATION)
		progress_shader.set_shader_parameter("progress_tail", progress)
	else:
		progress_shader.set_shader_parameter("progress_tail", progress)
		progress_shader.set_shader_parameter("progress", progress)
func _process(delta: float) -> void:

	# FPS с интервалом
	_update_fps(delta)

func _update_fps(delta: float) -> void:
	_time_passed += delta
	if _time_passed >= _refresh_interval:
		_time_passed = 0.0
		fps_label.text = "FPS " + str(int(Engine.get_frames_per_second()))


func get_tween() -> Tween:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT)
	return _tween	
