extends BaseSystem
class_name POIInteractionSystem

var run_entity:int=-1

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,  _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)
	event_bus.subscribe("poi_interacted", _on_poi_interacted)

func _on_poi_interacted(data: Dictionary) -> void:
	var poi_id = data.poi_id
	var player_id = data.player_id

	var comp = cs.get_component(poi_id, "POIComponent")
	match comp.name:
		"campfire":
			_change_day()
			


func _change_day():
	if run_entity ==-1:
		run_entity = get_entities_with(["RunComponent"])[0]
	var run_comp = cs.get_component(run_entity,"RunComponent")
	run_comp.current_day+=1
	
	event_bus.emit("day_changed", {"current_day": run_comp.current_day})
