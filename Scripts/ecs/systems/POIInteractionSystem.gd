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
		
	match comp.name:
		"campfire":
			var pos = cs.get_component(poi_id,"TransformComponent").position
			for camera in camera_arch.entities:
				var camera_comp = cs.get_component(camera, "CameraComponent")
				if camera_comp.owner_id == player_id:
					camera_comp.mode = CameraComponent.Mode.FOCUS
					var target_pos = Vector3(0.0,1.0,1.0)
					var poi_pos = cs.get_component(poi_id, "TransformComponent").position

					camera_comp.focus_from_pos = target_pos
					camera_comp.focus_target = Vector3.ZERO
					break
		"merchant":
			
			var campfire_position = Vector3.ZERO
			var pos = cs.get_component(poi_id,"TransformComponent").position
			for camera in camera_arch.entities:
				var camera_comp = cs.get_component(camera, "CameraComponent")
				if camera_comp.owner_id == player_id:
					camera_comp.mode = CameraComponent.Mode.FOCUS
					var target_pos = campfire_position
					var poi_pos = cs.get_component(poi_id, "TransformComponent").position
					var dir = (poi_pos - target_pos).normalized()
					var distance := 1.0
					var offset = Vector3(0.0,1.4,0.0)
					var poi_look_offset = offset+ distance *dir
					camera_comp.focus_from_pos = poi_pos + poi_look_offset
					camera_comp.focus_target = target_pos
					break
			#UIManager.merchant_panel.background_scene.update_camera_pos(campfire_position, pos)
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
