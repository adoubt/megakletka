extends BaseSystem
class_name GroundGenerationSystem


var ecs : Node
var days_arch: Archetype
const PUDDLE_LEVEL := -2.15

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus, _ecs: Node,):
	super._init(_entity_manager,_component_store,_event_bus)
	ecs = _ecs
	arch = cs.register_archetype(["GroundGenerationRequestComponent","GroundHeightComponent","GroundVisualComponent","RunComponent"])
	days_arch = cs.register_archetype(["DayComponent", "DayIdComponent"],["DeadComponent"])
func update(delta: float) ->void:
	for e in arch.entities:
		var run_comp = cs.get_component(e, "RunComponent")
		var ground = cs.get_component(e, "GroundHeightComponent")
		var visual = cs.get_component(e, "GroundVisualComponent")
		var current_day = run_comp.current_day
		var _seed = run_comp.seed
		var day_comp : DayComponent
		for d in days_arch.entities:
			var day_index = cs.get_component(d, "DayIdComponent").id
			if day_index == current_day:
				day_comp = cs.get_component(d, "DayComponent")
				break
		ground.generate(
			_seed + current_day, 
			day_comp.height_amp,
			day_comp.frequency,
			day_comp.puddles
		)
		_update_mesh(ground, visual)
		cs.remove_component(RUN,"GroundGenerationRequestComponent" )
		event_bus.emit("ground_generated", {"ground": ground})
		
	

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
		return Color(0.04, 0.06, 0.10) # холодная вода, почти чёрная
	elif h < 0.2:
		return Color(0.07, 0.11, 0.14) # мокрое холодное болото
	else:
		return Color(0.12, 0.15, 0.17) # холодные кочки / ил

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
