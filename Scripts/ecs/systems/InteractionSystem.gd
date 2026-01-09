extends BaseSystem
class_name Interactionsystem

func update(_delta: float) -> void:
	var players = get_entities_with(
		["PlayerComponent", "InRangeInteractionComponent"]
	)
	for player_id in players:
		if Input.is_action_just_pressed("interact"):
			var target_id = cs.get_component(player_id, "InRangeInteractionComponent").target_id
			if cs.get_component(target_id, "POIComponent").name == "wagon":
				UIManager.toggle_wagon_panel()
				
