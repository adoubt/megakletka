extends Node3D


@export var color_param_name := "ColorParameter"

@export var warm_color: Color = Color("ff8c40ff")   # 🔥 тепло
@export var cold_color: Color = Color("59a6ffff")  # ❄️ холод

@onready var mesh: MeshInstance3D = $Sphere
@onready var material: ShaderMaterial

var is_enabled := false
var default_color: Color


func _ready() -> void:
	if not mesh:
		push_error("ZoneVisual: MeshInstance3D not found")
		return

	material = mesh.get_surface_override_material(0)
	if not material:
		push_error("ZoneVisual: material_override is not ShaderMaterial")
		return

	default_color = material.get_shader_parameter(color_param_name)
	_set_visible(false)

func set_warm() -> void:
	_enable_with_color(warm_color)


func set_cold() -> void:
	_enable_with_color(cold_color)


func disable() -> void:
	if not material:
		return

	is_enabled = false
	_set_visible(false)
	material.set_shader_parameter(color_param_name, default_color)

func _enable_with_color(color: Color) -> void:
	if not material:
		return

	is_enabled = true
	_set_visible(true)
	material.set_shader_parameter(color_param_name, color)


func _set_visible(value: bool) -> void:
	if mesh:
		mesh.visible = value
