
extends Control

const ANIMATION_DURATION: float = 0.7
var offer_id:int = -1
var has_upgrade: bool = false
@onready var fps_label: Label = $HUD/VBoxContainer/Control/FPS

@onready var dayboard_panel:= $HUD/VBoxContainer/Control/MarginContainer/LeftPanel/Control3/DayBoardPanel

# === HP ===
@export var min_hp: float = 0.0
@export var max_hp: float = 100.0
@export var current_hp: float = 100.0:
	set = set_current_hp
@onready var current_hp_texture: ColorRect = $HUD/VBoxContainer/Control/MarginContainer/LeftPanel/Control2/HP/Control/MarginContainer/Control/CurrentHP
@onready var current_hp_label: Label = $HUD/VBoxContainer/Control/MarginContainer/LeftPanel/Control2/HP/Control/MarginContainer/Control/CurrentHPLabel
@onready var hp_shader: ShaderMaterial 

# === XP ===
@export var min_xp: float = 0.0
@export var max_xp: float = 100.0
@export var current_xp: float = 0.0:
	set = set_current_xp
@onready var current_xp_texture: ColorRect = $HUD/VBoxContainer/Header/CurrentXP
@onready var current_xp_label: Label = $HUD/VBoxContainer/Header/MarginContainer/CurrentXPLabel
@onready var xp_shader: ShaderMaterial 
@onready var current_level: Label = $HUD/VBoxContainer/Header/CurrentLevel

# === Technical ===
var _tween: Tween
var _time_passed := 0.0
var _refresh_interval := 0.5


func _ready() -> void:
	hp_shader = current_hp_texture.material
	xp_shader =  current_xp_texture.material
	update_current_hp_texture(0)
	update_current_xp_texture(0)

	visible = false

# ================= HP =================
func set_current_hp(new_current_hp: float):
	var diff = new_current_hp - current_hp
	current_hp = clampf(new_current_hp, min_hp, max_hp)
	update_current_hp_texture(sign(diff))
	update_current_hp(current_hp)

func update_current_hp(_value: float):
	current_hp_label.text = "%d / %d" % [int(_value), int(max_hp)]

func update_current_hp_texture(direction: int):
	var progress = current_hp  / (max_hp - min_hp)
	if direction < 0:
		get_tween().tween_property(hp_shader, "shader_parameter/progress_tail", progress, ANIMATION_DURATION)
		hp_shader.set_shader_parameter("progress", progress)
	elif direction > 0:
		get_tween().tween_property(hp_shader, "shader_parameter/progress", progress, ANIMATION_DURATION)
		hp_shader.set_shader_parameter("progress_tail", progress)
	else:
		hp_shader.set_shader_parameter("progress_tail", progress)
		hp_shader.set_shader_parameter("progress", progress)


# ================= XP =================
func set_current_xp(new_current_xp: float):
	var diff = new_current_xp - current_xp
	current_xp = clampf(new_current_xp, min_xp, max_xp)
	update_current_xp_texture(sign(diff))
	update_current_xp(current_xp)

func update_current_xp(_value: float):
	current_xp_label.text = "%d / %d" % [int(_value), int(max_xp)]

func update_current_xp_texture(_direction: int):
	var progress = (current_xp - min_xp) / (max_xp - min_xp)
	# XP растёт только вперёд, поэтому анимируем только progress
	if _direction < 0:
		get_tween().tween_property(xp_shader, "shader_parameter/progress_tail", progress, 0.2)
		xp_shader.set_shader_parameter("progress", progress)
	elif _direction > 0:
		get_tween().tween_property(xp_shader, "shader_parameter/progress", progress, ANIMATION_DURATION)
		xp_shader.set_shader_parameter("progress_tail", progress)
	else:
		xp_shader.set_shader_parameter("progress_tail", progress)
		xp_shader.set_shader_parameter("progress", progress)

# ================= Misc =================
func _process(delta: float) -> void:
	_update_fps(delta)

func _update_fps(delta: float) -> void:
	_time_passed += delta
	if _time_passed >= _refresh_interval:
		_time_passed = 0.0
		fps_label.text = "FPS %d" % int(Engine.get_frames_per_second())

func get_tween() -> Tween:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT)
	return _tween

	
	
func update_dayboard(data: Array):
	var current_day: int
	var day_index: int = 0 
	for day in data:
		if day.current: current_day = day_index
			
	pass
	
