extends BaseSystem
class_name GroundGenerationSystem

var run_entity : int = -1
var ecs : Node

const PUDDLE_LEVEL := -0.15
func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus, _ecs: Node,):
	super._init(_entity_manager,_component_store,_event_bus)
	ecs = _ecs
	event_bus.subscribe("day_changed", _on_day_changed)
	
	
func _on_day_changed(data: Dictionary = {}):
	
	if run_entity == -1:
		run_entity = get_entities_with([
			"RunComponent",
		])[0]

	var _seed = cs.get_component(run_entity, "SeedComponent")
	var ground = cs.get_component(run_entity, "GroundHeightComponent")
	var visual = cs.get_component(run_entity, "GroundVisualComponent")
	var current_day = cs.get_component(run_entity, "RunComponent").current_day
	var day_comp : DayComponent
	var days = get_entities_with(["DayComponent"])
	for d in days:
		var day_index = cs.get_component(d, "DayIdComponent").id
		if day_index == current_day:
			day_comp = cs.get_component(d, "DayComponent")
			break

	ground.generate(
		_seed.seed + data.current_day, 
		day_comp.height_amp,
		day_comp.frequency,
		day_comp.puddles
	)
	_update_mesh(ground, visual)

func _update_mesh(ground, visual):
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for z in range(ground.size_z - 1):
		for x in range(ground.size_x - 1):
			_add_quad(st, ground, x, z)

	var mesh := st.commit()

	if visual.mesh_instance == null:
		visual.mesh_instance = MeshInstance3D.new()
		visual.mesh_instance.material_override = _create_ground_material()
		ecs.add_child(visual.mesh_instance)

	visual.mesh_instance.mesh = mesh


func _add_quad(st: SurfaceTool, ground, x: int, z: int):
	var cs :float= ground.cell_size
	var half_x :float= (ground.size_x - 1) * cs * 0.5
	var half_z :float= (ground.size_z - 1) * cs * 0.5

	var idx :float= x + z * ground.size_x

	var h00 :float= ground.heights[idx]
	var h10 :float= ground.heights[idx + 1]
	var h01 :float= ground.heights[idx + ground.size_x]
	var h11 :float= ground.heights[idx + ground.size_x + 1]

	var p00 := Vector3(x*cs - half_x,     h00, z*cs - half_z)
	var p10 := Vector3((x+1)*cs - half_x, h10, z*cs - half_z)
	var p01 := Vector3(x*cs - half_x,     h01, (z+1)*cs - half_z)
	var p11 := Vector3((x+1)*cs - half_x, h11, (z+1)*cs - half_z)

	# ---- triangle 1
	var n1 := Plane(p00, p10, p11).normal
	_add_vertex(st, p00, n1, h00)
	_add_vertex(st, p10, n1, h10)
	_add_vertex(st, p11, n1, h11)

	# ---- triangle 2
	var n2 := Plane(p00, p11, p01).normal
	_add_vertex(st, p00, n2, h00)
	_add_vertex(st, p11, n2, h11)
	_add_vertex(st, p01, n2, h01)

# ======================================================
# VERTEX
# ======================================================

func _add_vertex(st: SurfaceTool, pos: Vector3, normal: Vector3, height: float):
	st.set_normal(normal)
	st.set_color(_height_to_color(height))
	st.add_vertex(pos)

# ======================================================
# COLOR LOGIC (БОЛОТО)
# ======================================================

func _height_to_color(h: float) -> Color:
	if h < PUDDLE_LEVEL:
		return Color(0.05, 0.07, 0.05) # вода / грязь
	elif h < 0.2:
		return Color(0.15, 0.22, 0.14) # мокрое болото
	else:
		return Color(0.28, 0.24, 0.18) # кочки

# ======================================================
# MATERIAL
# ======================================================

func _create_ground_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.roughness = 0.9
	mat.metallic = 0.0
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	return mat
