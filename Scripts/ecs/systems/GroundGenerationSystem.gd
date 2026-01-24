extends BaseSystem
class_name GroundGenerationSystem

var run_entity : int = -1
var ecs : Node
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
		ecs.add_child(visual.mesh_instance)

	visual.mesh_instance.mesh = mesh

func _add_quad(st, ground, x, z):
	var cell_size :float = ground.cell_size

	var half_x :float= (ground.size_x - 1) * cell_size * 0.5
	var half_z :float= (ground.size_z - 1) * cell_size * 0.5

	var h00 = ground.heights[x + z * ground.size_x]
	var h10 = ground.heights[x+1 + z * ground.size_x]
	var h01 = ground.heights[x + (z+1) * ground.size_x]
	var h11 = ground.heights[x+1 + (z+1) * ground.size_x]

	var p00 = Vector3(x*cell_size - half_x,     h00, z*cell_size - half_z)
	var p10 = Vector3((x+1)*cell_size - half_x, h10, z*cell_size - half_z)
	var p01 = Vector3(x*cell_size - half_x,     h01, (z+1)*cell_size - half_z)
	var p11 = Vector3((x+1)*cell_size - half_x, h11, (z+1)*cell_size - half_z)

	st.add_vertex(p00)
	st.add_vertex(p10)
	st.add_vertex(p11)

	st.add_vertex(p00)
	st.add_vertex(p11)
	st.add_vertex(p01)
