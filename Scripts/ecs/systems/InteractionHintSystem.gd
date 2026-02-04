extends BaseSystem
class_name InteractionHintSystem


func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store,_event_bus)
	
	arch = cs.register_archetype(
	["InRangeInteractionComponent", "PlayerComponent"],
	["DeadComponent"]
)

func update(_delta):
	for p in arch.entities:
		var ir := cs.get_component(p, "InRangeInteractionComponent")

		# --- СМЕНА / ПОТЕРЯ ЦЕЛИ ---
		if ir.previous_target_id != -1:
			_hide(ir.previous_target_id)

			# 🔥 ВАЖНО: закрываем UI ТОЛЬКО ЗДЕСЬ
			UIManager.close_all()

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

			
