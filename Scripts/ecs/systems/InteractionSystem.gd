extends BaseSystem
class_name Interactionsystem

func update(_delta: float) -> void:
	var players = get_entities_with(
		["PlayerComponent", "InRangeInteractionComponent"]
	)
	for player_id in players:	

		var input = cs.get_component(player_id, "InputComponent")
		
		var inter = cs.get_component(player_id, "InRangeInteractionComponent")
		
				
		if input.interact_pressed:
			inter.is_interacting = true
			inter.progress = 0.0

		if inter.is_interacting and input.interact_held:
			inter.progress += _delta

			if inter.progress >= inter.interact_time:
				event_bus.emit("poi_interacted", {
					"poi_id": inter.target_id,
					"player_id": player_id,
					"type": "hold"
				})
				inter.is_interacting = false
				inter.progress = 0.0

		elif input.interact_released and inter.is_interacting:
			event_bus.emit("poi_interacted", {
				"poi_id": inter.target_id,
				"player_id": player_id,
				"type": "tap"
			})
			inter.is_interacting = false
			inter.progress = 0.0

	
