extends BaseSystem
class_name TargetSystem

func update(_delta: float) -> void:
	var entities = get_entities_with(["TransformComponent", "TargetComponent"])

	for entity_id in entities:
		var target_data = cs.get_component(entity_id, "TargetComponent")
		if not target_data.active:
			continue

		var transform = cs.get_component(entity_id, "TransformComponent")
		if transform == null:
			continue

		# Находим ближайшего игрока
		var nearby_players = get_entities_with(["ControllerStateComponent"])
		var nearest_id = -1
		var nearest_dist = INF

		for player_id in nearby_players:
			var player_transform = cs.get_component(player_id, "TransformComponent")
			if player_transform == null:
				continue

			var dist = transform.position.distance_to(player_transform.position)
			if dist < target_data.aggro_radius and dist < nearest_dist:
				nearest_id = player_id
				nearest_dist = dist

		target_data.target_id = nearest_id
