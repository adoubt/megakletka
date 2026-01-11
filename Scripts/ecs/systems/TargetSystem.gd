extends BaseSystem
class_name TargetSystem

func update(_delta: float) -> void:
	var enemies = get_entities_with(["TransformComponent", "TargetComponent"])
	if enemies.is_empty():
		return

	# Берём игроков и фильтруем живых
	var players = get_entities_with(["PlayerComponent", "TransformComponent"])
	var alive_players := []
	for pid in players:
		if not cs.has_component(pid, "DeadComponent"):
			alive_players.append(pid)

	var player_id := -1
	var player_pos := Vector3.ZERO
	if alive_players.size() > 0:
		player_id = alive_players.pick_random()
		player_pos = cs.get_component(player_id, "TransformComponent").position

	for enemy_id in enemies:
		var target = cs.get_component(enemy_id, "TargetComponent")
		var transform = cs.get_component(enemy_id, "TransformComponent")

		# Очистка таргета
		if target.target_id != -1:
			if cs.has_component(target.target_id, "DeadComponent"):
				target.target_id = -1
				continue

			var target_transform = cs.get_component(target.target_id, "TransformComponent")
			if transform.position.distance_to(target_transform.position) > target.aggro_radius:
				target.target_id = -1
			continue

		# Назначение таргета (только живой игрок)
		if player_id != -1 and transform.position.distance_to(player_pos) <= target.aggro_radius:
			target.target_id = player_id
