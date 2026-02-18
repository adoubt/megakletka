extends BaseSystem
class_name InteractionHintSystem

var camera_arch :Archetype
func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store,_event_bus)
	
	arch = cs.register_archetype(
	["InRangeInteractionComponent", "PlayerComponent"],
	["DeadComponent"]
)
	camera_arch = cs.register_archetype(["CameraComponent"])
	event_bus.subscribe("poi_panel_closed", _on_poi_panel_closed)
func update(_delta):
	for p in arch.entities:
		var ir := cs.get_component(p, "InRangeInteractionComponent")

		# --- СМЕНА / ПОТЕРЯ ЦЕЛИ ---
		if ir.previous_target_id != -1:
			_hide(ir.previous_target_id)

			# 🔥 ВАЖНО: закрываем UI ТОЛЬКО ЗДЕСЬ
			UIManager.close_all(["HUD"])
			UIManager.hud.hide_item_tool_tip()
			_return_camera(p)
			ir.previous_target_id = -1
			ir.hint_visible = false
			
		# --- НЕТ ЦЕЛИ ---
		if ir.target_id == -1:
			continue

		# --- UI ОТКРЫТО ---
		if UIManager._any_ui_open():
			if ir.hint_visible:
				_hide(ir.target_id)
				ir.hint_visible = false
			continue

		# --- ПОКАЗАТЬ ОДИН РАЗ ---
		if not ir.hint_visible:
			_show(ir.target_id)
			ir.hint_visible = true



func _show(target_id: int):
	if target_id == -1:
		return
	var render = cs.get_component(target_id, "RenderComponent")
	if render and render.instance:
		render.instance.show_hint()
		render.instance.show_hint_r()

func _hide(target_id: int):
	if target_id == -1:
		return
	var render = cs.get_component(target_id, "RenderComponent")
	if render and render.instance:
		render.instance.hide_hint()
		render.instance.hide_hint_r()

func _return_camera(owner_id:int) -> void:
	for camera in camera_arch.entities:
				var camera_comp = cs.get_component(camera, "CameraComponent")
				if camera_comp.owner_id == owner_id:
					if camera_comp.mode == CameraComponent.Mode.FOCUS:
						camera_comp.return_start_pos = camera_comp.camera_instance.global_position
						camera_comp.return_start_rot = camera_comp.camera_instance.global_basis
						camera_comp.transition_elapsed = 0.0
						camera_comp.mode = CameraComponent.Mode.BLEND_TO_FOLLOW
						
					return	
	
func _on_poi_panel_closed(data:Dictionary) -> void:
	var owner_id = data.owner_id
	_return_camera(owner_id)
