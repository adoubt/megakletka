extends BaseSystem
class_name POIInteractionSystem



func _init(_entity_manager: EntityManager, _component_store: ComponentStore,  _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)
	event_bus.subscribe("poi_interacted", _on_poi_interacted)

func _on_poi_interacted(data: Dictionary) -> void:
	var poi_id = data.poi_id
	var player_id = data.player_id

	var comp = cs.get_component(poi_id, "POIComponent")
	match comp.name:
		"campfire":
			event_bus.emit("change_day_request")
			
