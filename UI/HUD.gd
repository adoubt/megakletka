@tool
extends Control

const ANIMATION_DURATION:float= 0.7

@onready var fps_label: Label = $HUD/VBoxContainer/Control/FPS

@export var min_hp: float = 0.0
@export var max_hp: float = 100.0
@export var current_hp: float = 100.0:
	set = set_current_hp
@onready var progress_shader: ShaderMaterial 
@onready var current_hp_texture: ColorRect = $HUD/VBoxContainer/Control/MarginContainer/LeftPanel/Control2/HP/Control/MarginContainer/Control/CurrentHp
@onready var current_hp_label: Label = $HUD/VBoxContainer/Control/MarginContainer/LeftPanel/Control2/HP/Control/MarginContainer/Control/CurrentHPLabel
@onready var current_exp_texture : Label  
func _ready() ->void:
	progress_shader = current_hp_texture.material
	update_current_hp_texture(0)

func set_current_hp(new_current_hp:float):
	var diff = new_current_hp - current_hp 
	current_hp  = clampf(new_current_hp,min_hp,max_hp)
	update_current_hp_texture(sign(diff))
	update_current_hp(current_hp)
var _tween: Tween
var _time_passed := 0.0
var _refresh_interval := 0.5  # обновляем FPS раз в 0.5 сек

	# FPS обновится на первом цикле _process
func update_current_hp(_value:float):
	current_hp_label.text= str(int(_value)) + "/" + str(int(max_hp))
func update_current_hp_texture(direction:int):
	var progress = current_hp / (max_hp - min_hp)
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
