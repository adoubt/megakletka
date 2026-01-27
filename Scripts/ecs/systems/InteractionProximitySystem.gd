extends BaseSystem
class_name InteractionProximitySystem

##TODO InteractionProximitySystem can be faster using grid cells
func update(_delta: float) -> void:
	var players := get_entities_with(
		["PlayerComponent"]
	)

	var targets := get_entities_with(
		["TransformComponent", "InteractionTargetComponent"]
	)

	for p in players:
		var p_tf = cs.get_component(p, "TransformComponent")
		

		var best_target := -1
		var best_score := -INF

		for t in targets:
			var t_tf = cs.get_component(t, "TransformComponent")
			var target = cs.get_component(t, "InteractionTargetComponent")

			var dist_sq = p_tf.position.distance_squared_to(t_tf.position)
			if dist_sq > target.radius * target.radius:
				continue

			# приоритет + ближе = лучше
			var score = target.priority * 1000 - dist_sq
			if score > best_score:
				best_score = score
				best_target = t

		if best_target != -1:
			_set_interaction(p, best_target)
		else:
			var target = cs.get_component(p, "InRangeInteractionComponent")
			if target:
				var target_render = cs.get_component(target.target_id, "RenderComponent")
				if target_render.instance:
					target_render.instance.hide_hint()
				cs.remove_component(p, "InRangeInteractionComponent")
				UIManager.close_all()
				if cs.get_component(p, "ActiveOfferComponent"):
					var player_rander = cs.get_component(p, "RenderComponent")
				
					if player_rander.instance:
						player_rander.instance.show_level_up()
						
func _set_interaction(player_id: int, target_id: int):
	if cs.has_component(player_id, "InRangeInteractionComponent"):
		var cur = cs.get_component(player_id, "InRangeInteractionComponent")
		if cur.target_id == target_id:
			return
		cur.target_id = target_id
	else:
		var comp := InRangeInteractionComponent.new()
		comp.target_id = target_id
		cs.add_component(player_id, "InRangeInteractionComponent", comp)
		var player_rander = cs.get_component(player_id, "RenderComponent")
		if player_rander.instance:
			player_rander.instance.hide_level_up()
