extends Node3D

@onready var body: MeshInstance3D = $Model/Body

func ensure_unique_base_material() -> StandardMaterial3D:
	var mat := body.material_override
	if mat == null:
		mat = StandardMaterial3D.new()
		mat.resource_local_to_scene = true
		body.material_override = mat
	elif not mat.resource_local_to_scene:
		mat = mat.duplicate()
		mat.resource_local_to_scene = true
		body.material_override = mat
	return mat

func set_flash_material(flash_mat: Material) -> void:
	if body.material_override:
		body.material_override.next_pass = flash_mat

func clear_flash_material() -> void:
	if body.material_override:
		body.material_override.next_pass = null
