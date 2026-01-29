extends BaseSystem
class_name POIInteractionSystem



func _init(_entity_manager: EntityManager, _component_store: ComponentStore,  _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)
	event_bus.subscribe("poi_interacted", _on_poi_interacted)

func _on_poi_interacted(data: Dictionary) -> void:
	var poi_id = data.poi_id
	var player_id = data.player_id

	var comp = cs.get_component(poi_id, "POIComponent")
	if comp.is_mushroom:
		cs.add_component(poi_id, "MushroomEatedComponent", MushroomEatedComponent.new(player_id))
		return
		
	match comp.name:
		"campfire":
			event_bus.emit("change_day_request")
		"merchant":
			var pos = cs.get_component(poi_id,"TransformComponent").position
			var render = cs.get_component(poi_id,"RenderComponent")
			var it = cs.get_component(poi_id,"InteractionTargetComponent")
			if it.interact_type & InteractType.PRESS:
				render.instance.hide_hint()
			if it.interact_type & InteractType.HOLD:
				render.instance.hide_hint_r()
			UIManager.merchant_panel.background_scene.update_camera_pos(pos)
			UIManager.open_merchant_panel()
		_:
			printerr("POI not exist")
