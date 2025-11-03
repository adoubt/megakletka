extends BaseSystem
class_name TargetSystem

func update(_delta: float) -> void:
	var enemies = get_entities_with(["TransformComponent", "TargetComponent"])
	if enemies.is_empty():
		return

	# Получаем игрока (у нас он один)
	var players = get_entities_with(["ControllerStateComponent", "TransformComponent"])
	if players.is_empty():
		return

	var player_id = players[0]
	var player_transform = cs.get_component(player_id, "TransformComponent")
	if player_transform == null:
		return

	# Кэшируем позицию игрока один раз
	var player_pos = player_transform.position

	for enemy_id in enemies:
		var target_data = cs.get_component(enemy_id, "TargetComponent")
		if not target_data.active:
			continue

		var transform = cs.get_component(enemy_id, "TransformComponent")
		if transform == null:
			continue

		var dist = transform.position.distance_to(player_pos)
		if dist < target_data.aggro_radius:
			target_data.target_id = player_id
		else:
			target_data.target_id = -1
