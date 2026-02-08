extends BaseSystem
class_name NavigationSystem

var run_arch
var day_arch
##TODO can work with request instead frame tick
func _init(_em: EntityManager, _cs: ComponentStore, _bus: EventBus):
	super._init(_em, _cs, _bus)

	run_arch = cs.register_archetype(
		["RunComponent","DaySelectRequestComponent"]
	)

	day_arch = cs.register_archetype(
		["DayComponent", "GraphNodeComponent"],
		
	)
	
func update(_delta):
	if run_arch.entities.is_empty():
		return

	
	var run: RunComponent = cs.get_component(RUN, "RunComponent")

	if run.current_day == -1:
		#var lobby_graph = cs.get_component(run.current_day, "GraphNodeComponent")
		cs.add_component(2, "ReachableComponent", ReachableComponent.new())
		
				#cs.get_component()
		return		
			
	var current_graph: GraphNodeComponent = cs.get_component(
		run.current_day,
		"GraphNodeComponent"
	)
	
	for day_id in day_arch.entities :
		if cs.has_component(day_id, "ReachableComponent") :
			cs.remove_component(day_id, "ReachableComponent")

	for target_id in current_graph.exits:
		if !cs.has_component(target_id, "ReachableComponent"):
			cs.add_component(target_id, "ReachableComponent", ReachableComponent.new())
	
