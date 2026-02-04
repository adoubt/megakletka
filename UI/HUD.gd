
extends Control
var has_upgrade:bool = false
const ANIMATION_DURATION: float = 0.7
var offer_id:int = -1

@onready var fps_label: Label = %FPS

@onready var combat_panel: PanelContainer = %CombatPanel
#@onready var combat_panel_background :TextureRect = %CombatPanelBackground
@onready var current_day: Label = %CurrentDay
@onready var log_balance: Label = %LogBalance
@onready var phase_label: Label = %PhaseLabel
var previous_combat_progress: float = 1.0
var combat_progress : float = 1.0
@export var max_combat_progress: float = 50.0
@onready var combat_progress_shader: ShaderMaterial 
##Stats

var damage: float=0.0:
	set(value):
		damage = value
		%DamageLabel.text = str(value)
var armor: float = 0.0:
	set(value):
		armor = value
		%ArmorLabel.text = str(value)
var pierce:float = 0.0:
	set(value):
		pierce = value
		%PierceLabel.text = str(int(value))
var movespeed: float=0.0:
	set(value):
		movespeed = value
		%MovespeedLabel.text = str(value)
var attack_speed:float =0.0:
	set(value):
		attack_speed = value
		%AttackSpeedLabel.text = str(value)
var jumps_left:float =0.0:
	set(value):
		jumps_left = value
		%JumpLeftLabel.text = str(int(value))
var jumps_count:float =0.0:
	set(value):
		jumps_count = value
		%JumpsCountLabel.text = str(int(value))
var xp_gain:float =0.0:
	set(value):
		xp_gain = value
		%XPGainLabel.text = str(value)
var duration:float =0.0:
	set(value):
		duration = value
		%DurationLabel.text = str(value)
var required_xp:float= 0.0:
	set(value):
		required_xp = value
		%RequiredXPLabel.text = str(value)
var current_level:float= 0.0:
	set(value):
		current_level = value
		%CurrentLevelLabel.text = str(int(value))
var slots_count:float= 0.0:
	set(value):
		slots_count = value
		%SlotsCountLabel.text = str(int(value))
# === HP ===
@export var min_hp: float = 0.0
@export var max_hp: float = 5.0:
	set = set_max_hp

var previous_current_hp:float = 10
@export var current_hp: float = 0.0:
	set = set_current_hp
@onready var current_hp_texture: TextureRect = %CurrentHp
@onready var current_hp_label: Label = %CurrentHPLabel
@onready var hp_shader: ShaderMaterial 

@onready var max_hp_texture: TextureRect= %MaxHp

# === XP ===
@export var min_xp: float = 0.0


var previous_current_xp: float = 0.0
@export var current_xp: float = 10.0:
	set = set_current_xp
@onready var current_xp_texture: ColorRect = %CurrentXP
@onready var current_xp_label: Label = %CurrentXPLabel
@onready var xp_shader: ShaderMaterial 



# === Technical ===
var _hp_tween: Tween
var _combat_tween: Tween
var _xp_tween: Tween
var _time_passed := 0.0
var _refresh_interval := 0.5


func _ready() -> void:
	hp_shader = current_hp_texture.material
	xp_shader =  current_xp_texture.material
	combat_progress_shader = combat_panel.material
	#update_current_hp_texture(1)
	#update_current_xp_texture(1)
	set_current_combat_progress(1.0)
	hide_combat_progress()
	_set_children_mouse_ignore(self)
	visible = false
	
func refresh():
	resize_hp_bar(max_hp)
func set_current_combat_progress(new_combat_progress: float):
	var diff = new_combat_progress - previous_combat_progress
	combat_progress = clampf(new_combat_progress, 0.0, 1.0)
	previous_combat_progress = combat_progress
	update_combat_progress_texture(sign(diff))
	#update_current_hp(combat_progress)
	
	
func update_combat_progress_texture(direction: int):
	var progress = combat_progress  
	if direction < 0:
		get_combat_tween().tween_property(combat_progress_shader, "shader_parameter/progress_tail", progress, ANIMATION_DURATION)
		combat_progress_shader.set_shader_parameter("progress", progress)
	elif direction > 0:
		get_combat_tween().tween_property(combat_progress_shader, "shader_parameter/progress", progress, ANIMATION_DURATION)
		combat_progress_shader.set_shader_parameter("progress_tail", progress)
	else:
		combat_progress_shader.set_shader_parameter("progress_tail", progress)
		combat_progress_shader.set_shader_parameter("progress", progress)
# ================= HP =================
func set_current_hp(new_current_hp: float):

	var diff = new_current_hp - previous_current_hp
	previous_current_hp = current_hp
	current_hp = clampf(new_current_hp, min_hp, max_hp)
	
	update_current_hp_texture(sign(diff))
	%CurrentHPLabel.text = str(current_hp)
	
func set_max_hp(new_max_hp:float):
	max_hp = new_max_hp
	%MaxHPLabel.text = str(new_max_hp)
	resize_hp_bar(max_hp)
	
func resize_hp_bar(new_max_hp:float):
	var _size = new_max_hp * 20
	max_hp_texture.custom_minimum_size.x = _size
	current_hp_texture.custom_minimum_size.x = _size
	
	


func fmt(v: float) -> String:
	if is_equal_approx(v, round(v)):
		return str(int(v))
	return "%.1f" % v

func update_current_hp_texture(direction: int):
	var progress = current_hp  / (max_hp - min_hp)
	if direction < 0:
		get_hp_tween().tween_property(hp_shader, "shader_parameter/progress_tail", progress, ANIMATION_DURATION)
		hp_shader.set_shader_parameter("progress", progress)
	elif direction > 0:
		get_hp_tween().tween_property(hp_shader, "shader_parameter/progress", progress, ANIMATION_DURATION)
		hp_shader.set_shader_parameter("progress_tail", progress)
	else:
		hp_shader.set_shader_parameter("progress_tail", progress)
		hp_shader.set_shader_parameter("progress", progress)


# ================= XP =================
func set_current_xp(new_current_xp: float):
	
	var diff = new_current_xp - previous_current_xp
	current_xp = clampf(new_current_xp, min_xp, required_xp)
	previous_current_xp = current_xp
	update_current_xp_texture(sign(diff))
	update_current_xp(current_xp)

func update_current_xp(_value: float):
	current_xp_label.text = str(int(_value))

func update_current_xp_texture(_direction: int):
	var progress = (current_xp - min_xp) / (required_xp - min_xp)
	# XP растёт только вперёд, поэтому анимируем только progress
	if _direction < 0:
		get_xp_tween().tween_property(xp_shader, "shader_parameter/progress_tail", progress, 0.2)
		xp_shader.set_shader_parameter("progress", progress)
	elif _direction > 0:
		get_xp_tween().tween_property(xp_shader, "shader_parameter/progress", progress, ANIMATION_DURATION)
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

func get_hp_tween() -> Tween:
	if _hp_tween:
		_hp_tween.kill()
	_hp_tween = create_tween().set_ease(Tween.EASE_OUT)
	return _hp_tween

func get_xp_tween() -> Tween:
	if _xp_tween:
		_xp_tween.kill()
	_xp_tween = create_tween().set_ease(Tween.EASE_OUT)
	return _xp_tween

func get_combat_tween() -> Tween:
	if _combat_tween:
		_combat_tween.kill()
	_combat_tween = create_tween().set_ease(Tween.EASE_OUT)
	return _combat_tween
	
	
func update_dayboard(data: Array):
	var current_day: int = -1
	var day_index: int = 0 
	for day in data:
		if day.current:
			current_day = day_index
			
	pass
	
func set_current_day(value:int) -> void:
	current_day.text = "Day " + str(value)

func set_current_log_balance(value: int) -> void:
	log_balance.text = str(value)

func set_current_phase(value:int) -> void:
	phase_label.text = "Phase " + str(value)

func show_combat_progress() -> void:
	set_current_phase(1)
	#combat_panel_background.show()
	combat_panel.show()
	
func hide_combat_progress() -> void:
	#combat_panel_background.hide()
	combat_panel.hide()

func _set_children_mouse_ignore(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_set_children_mouse_ignore(child)
