extends BaseSystem
class_name XPPickUpSystem

func update(delta: float) -> void:
	var players = get_entities_with(["PlayerComponent"],["DeadComponent"])
	var orbs = get_entities_with(["PickUpComponent"],["DeadComponent"])

	if players.is_empty() or orbs.is_empty():
		return

	var player_id = players[0]
	var p_transform = cs.get_component(player_id, "TransformComponent")
	var target_pos = p_transform.position + Vector3(0.0,0.7,0.0)
	var p_level = cs.get_component(player_id, "LevelComponent")
	var pickup_radius = cs.get_component(player_id, "XPPickUpRangeComponent").final_value

	for orb_id in orbs:
		var pickup = cs.get_component(orb_id, "PickUpComponent")
		var orb_transform = cs.get_component(orb_id, "TransformComponent")

		# 1. Если орб ещё НЕ магнитится
		#    — проверяем радиус
		if !pickup.magnetized:
			var dist = target_pos.distance_to(orb_transform.position)
			if dist <= pickup_radius:
				pickup.magnetized = true
				pickup.speed = 0.0
			else:
				continue

		# 2. Если магнитится — летим к игроку
		pickup.speed += delta * 30.0 # ускорение
		var dir = (target_pos - orb_transform.position).normalized()
		orb_transform.position += dir * pickup.speed * delta

		# 3. Если долетел — подбираем
		if orb_transform.position.distance_to(target_pos) < 0.1:
			# добавляем XP, если есть XPRewardComponent
			var reward = cs.get_component(orb_id, "XPRewardComponent")
			if reward:
				p_level.current_xp += reward.final_value * cs.get_component(player_id,"XPMultComponent").final_value

			# можно универсально: если есть компонент GoldReward — добавляешь золото
			# если есть HealReward — хилишь — всё в одном месте
			
			# удаляем объект
			cs.add_component(orb_id, "DeadComponent", DeadComponent.new())
