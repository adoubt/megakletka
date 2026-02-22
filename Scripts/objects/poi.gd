extends Node
@onready var hint: Node3D
@onready var hint_r: Node3D 
@onready var r_progress: MeshInstance3D 
@export var current_progress_value: float= 0.0:
	set = set_current_progress
@export var min_value: float = 0.0
@export var max_value: float = 1.0
var zone: Node3D

@onready var slots_root: Node3D = $SlotsRoot
@onready var progress_shader: ShaderMaterial 
func _ready() -> void:
	hint = get_node_or_null("Hint")
	hint_r = get_node_or_null("HintR")
	r_progress = get_node_or_null("HintR/RProgress")
	hide_hint()
	hide_hint_r()
	#r_progress.mesh.material.set_billboard_mode(BaseMaterial3D.BILLBOARD_FIXED_Y) 
	if r_progress: 
		progress_shader =  r_progress.mesh.material
		_update_current_progress(0.0)
	zone = get_node_or_null("Zone")
	if zone: 
		zone.set_cold()
func show_hint() -> void:
	if hint:
		hint.show()
func hide_hint() -> void:
	if hint:
		hint.hide()
	
func show_hint_r() -> void:
	if hint_r:
		hint_r.show()
func hide_hint_r() -> void:
	if hint_r:
		hint_r.hide()
	
func get_subview_port() -> SubViewport:
	return $CameraPivot/SubViewport


func set_current_progress(value: float) -> void :
	#var diff = new_current_hp - current_hp
	current_progress_value = clampf(value, min_value, max_value)
	
	_update_current_progress(current_progress_value)
	
func _update_current_progress(value:float)-> void :
	var progress = value / (max_value - min_value) 
	progress_shader.set_shader_parameter("progress",progress)
