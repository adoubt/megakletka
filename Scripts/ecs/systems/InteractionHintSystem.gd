extends BaseSystem
class_name InteractionHintSystem

func update(_delta):
	var players := get_entities_with(
		["InRangeInteractionComponent", "PlayerComponent"],
		
	)

	for p in players:
	
		var ir := cs.get_component(p, "InRangeInteractionComponent")
		var render = cs.get_component(ir.target_id, "RenderComponent")
		if not render.instance:
			return
			
		var it = cs.get_component(ir.target_id,"InteractionTargetComponent")
		if UIManager._any_ui_open():
			continue
		if it.interact_type & InteractType.PRESS:
			render.instance.show_hint()
		if it.interact_type & InteractType.HOLD:
			render.instance.show_hint_r()
			
