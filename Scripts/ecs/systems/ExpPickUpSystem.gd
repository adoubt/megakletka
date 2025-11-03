extends BaseSystem
class_name ExpPickUpSystem




func update(_delta: float) -> void:
	var players = get_entities_with(["PlayerComponent", "TransformComponent", "ExpPickUpRangeComponent"])
	var exp_orbs = get_entities_with(["TransformComponent", "ExpRewardComponent"])

	if players.is_empty() or exp_orbs.is_empty():
		return

	for p_id in players:
		var p_transform = cs.get_component(p_id, "TransformComponent")
		var p_exp = cs.get_component(p_id, "CurrentExpComponent")
		var pickup_radius = cs.get_component(p_id, "ExpPickUpRangeComponent").final_value
		for e_id in exp_orbs:
			var orb_transform = cs.get_component(e_id, "TransformComponent")
			var dist = p_transform.position.distance_to(orb_transform.position)

			if dist <= pickup_radius:
				# Добавляем опыт игроку
				var reward = cs.get_component(e_id, "ExpRewardComponent").final_value
				p_exp.final_value += reward

				# Помечаем икспу как собранную
				cs.add_component(e_id, "DeadComponent", DeadComponent.new())

				# Можно добавить небольшой визуальный эффект
				# var fx_id = em.create_entity()
				# cs.add_component(fx_id, "ParticleComponent", PickupFxComponent.new(orb_transform.position))

				# break если орб может собираться только одним игроком
				break
