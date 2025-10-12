#@tool
extends Node3D
@export_group("Materials")
@export var legs_material: Material = null:
	set(value):

		set_mat($legs, value)
		legs_material = value
			
@export var body_material: Material = null:
	set(value):
		set_mat($body, value)
		body_material = value

@export var eye_material: Material = null:
	set(value):
		set_mat($eye, value)
		eye_material = value
		
@export var blades_material: Material = null:
	set(value):
		set_mat($Blades/Blade2pivot, value)
		set_mat($Blades/Blade3pivot, value)
		set_mat($Blades/Blade4pivot, value)
		set_mat($Blades/Blade1pivot, value)	
		blades_material = value
@export_subgroup("Flashlight Material")
@export var front_off: Material = null:
	set(value):
		set_mat($lights/front/Off, value)
		front_off = value

@export var front_on: Material = null:
	set(value):
		set_mat($lights/front/On, value)
		front_on = value

@export var back_off: Material = null:
	set(value):
		set_mat($lights/back/Off, value)
		back_off = value

@export var back_on: Material = null:
	set(value):
		set_mat($lights/back/On, value)
		back_on = value
		
@onready var model: Node3D = $"."

@export_group("Flashlight")		
@export var front: bool = false:
	set(value):
		if Engine.is_editor_hint():
			$lights/front/On.visible = value
			front = value

@export var back: bool = false:
	set(value):
		if Engine.is_editor_hint():
			$lights/back/On.visible = value
			back = value
		
func set_mat(part: Node3D, mat: Material):
	if not part:
		return
	for child in part.get_children():
		if child is MeshInstance3D and child.mesh:
			child.mesh.surface_set_material(0, mat)
			

	
		
