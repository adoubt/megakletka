extends BaseSystem
class_name DaySelectionSystem




func _init(_em, _cs, _bus):
	super._init(_em, _cs, _bus)

	arch = cs.register_archetype(["RunComponent", "DaySelectRequestComponent"]
)

func update(_delta):
	var entities = arch.entities.duplicate()
	for run_id in entities:
		var run: RunComponent = cs.get_component(run_id, "RunComponent")
		var req: = cs.get_component(run_id, "DaySelectRequestComponent")
		
		if !cs.has_component(req.target_day, "ReachableComponent"):
			cs.remove_component(run_id, "DaySelectRequestComponent")
			continue
		

		run.current_day = req.target_day
		
		cs.add_component(RUN, "GroundGenerationRequestComponent", GroundGenerationRequestComponent.new(req.target_day))
		cs.add_component(run_id, "DayEnterRequestComponent", DayEnterRequestComponent.new(req.target_day))

		cs.remove_component(run_id, "DaySelectRequestComponent")
