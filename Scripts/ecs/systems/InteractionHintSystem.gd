extends BaseSystem
class_name InteractionUISystem

func update(_delta):
	var players := get_entities_with(
		["InRangeInteractionComponent", "PlayerComponent"],
		
	)

	for p in players:
	
		var ir := cs.get_component(p, "InRangeInteractionComponent")
		var render = cs.get_component(ir.target_id, "RenderComponent")
		if render.instance:
			render.instance.show_hint()
			render.instance.show_hint_r()
