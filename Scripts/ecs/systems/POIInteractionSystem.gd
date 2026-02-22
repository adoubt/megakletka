extends BaseSystem
class_name POIInteractionSystem

var item_arch: Archetype
var ability_arch: Archetype
var camera_arch: Archetype
func _init(_entity_manager: EntityManager, _component_store: ComponentStore,  _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)
	event_bus.subscribe("poi_interacted", _on_poi_interacted)
	item_arch = cs.register_archetype(["ItemComponent"], ["DeadComponent"])
	ability_arch = cs.register_archetype(["ItemAbilityComponent"], ["DeadComponent"])
	camera_arch = cs.register_archetype(["CameraComponent"])
func _on_poi_interacted(data: Dictionary) -> void:
	var poi_id = data.poi_id
	var player_id = data.player_id

	var comp = cs.get_component(poi_id, "POIComponent")
	if comp.is_mushroom:
		cs.add_component(poi_id, "MushroomEatedComponent", MushroomEatedComponent.new(player_id))
		return
	UIManager.close_hat()	
	match comp.name:
		"campfire":
			
			for camera in camera_arch.entities:
				var camera_comp = cs.get_component(camera, "CameraComponent")
				if camera_comp.owner_id == player_id:
					camera_comp.mode = CameraComponent.Mode.FOCUS
					var poi_pos = cs.get_component(poi_id, "TransformComponent").position
					var player_pos = cs.get_component(player_id, "TransformComponent").position

					var focus_pos = poi_pos + Vector3(0.0, 0.3, 0.0)
					var player_eye_pos = player_pos + Vector3(0.0, 1.6, 0.0)

					var dir = (player_eye_pos - focus_pos).normalized()

					var distance := 1.4
					var camera_pos = focus_pos + dir * distance

					camera_comp.focus_target = focus_pos
					camera_comp.focus_from_pos = camera_pos
					break
			var render = cs.get_component(poi_id,"RenderComponent")
			var it = cs.get_component(poi_id,"InteractionTargetComponent")
			_update_items_data(poi_id)
			if it.interact_type & InteractType.PRESS:
				render.instance.hide_hint()
			if it.interact_type & InteractType.HOLD:
				render.instance.hide_hint_r()
			
			UIManager.open_campfire()
		"merchant":
			
			
			for camera in camera_arch.entities:
				var camera_comp = cs.get_component(camera, "CameraComponent")
				if camera_comp.owner_id == player_id:
					camera_comp.mode = CameraComponent.Mode.FOCUS
			
					var poi_pos = cs.get_component(poi_id, "TransformComponent").position
					var player_pos = cs.get_component(player_id, "TransformComponent").position
					var focus_pos = poi_pos + Vector3(0.0, 1.3, 0.0)
					var player_eye_pos = player_pos + Vector3(0.0, 1.6, 0.0)
					var dir = (player_eye_pos - focus_pos).normalized()

					var distance := 1.0
					var camera_pos = focus_pos + dir * distance

					camera_comp.focus_target = focus_pos
					camera_comp.focus_from_pos = camera_pos
					break
			
			var render = cs.get_component(poi_id,"RenderComponent")
			var it = cs.get_component(poi_id,"InteractionTargetComponent")
			_update_items_data(poi_id)
			if it.interact_type & InteractType.PRESS:
				render.instance.hide_hint()
			if it.interact_type & InteractType.HOLD:
				render.instance.hide_hint_r()
			
			UIManager.open_merchant_panel()
		_:
			printerr("POI not exist")
func _update_items_data(owner_id: int) ->void:
	for item in item_arch.entities:
		if cs.get_component(item, "ItemComponent").owner_id == owner_id:
			cs.add_component(item, "ItemViewBuildRequestComponent", ItemViewBuildRequestComponent.new())
