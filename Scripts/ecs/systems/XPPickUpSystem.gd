extends BaseSystem
class_name XPPickUpSystem




func update(_delta: float) -> void:
	var players = get_entities_with(["PlayerComponent"],["DeadComponent"])
	var exp_orbs = get_entities_with(["PickUpComponent", "XPRewardComponent"],["DeadComponent"])

	if players.is_empty() or exp_orbs.is_empty():
		return

	for p_id in players:
		var p_transform = cs.get_component(p_id, "TransformComponent")
		var p_level = cs.get_component(p_id, "LevelComponent")
		var pickup_radius = cs.get_component(p_id, "XPPickUpRangeComponent").final_value
		for e_id in exp_orbs:
			var orb_transform = cs.get_component(e_id, "TransformComponent")
			var dist = p_transform.position.distance_to(orb_transform.position)

			if dist <= pickup_radius:
				# Добавляем опыт игроку
				var reward = cs.get_component(e_id, "XPRewardComponent").final_value
				p_level.current_xp += reward * cs.get_component(p_id,"XPMultComponent").final_value

				# Помечаем икспу как собранную
				cs.add_component(e_id, "DeadComponent", DeadComponent.new())

				
				break
