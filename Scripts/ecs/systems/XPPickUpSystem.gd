extends BaseSystem
class_name XPPickUpSystem

func update(_delta: float) -> void:
	var picked := get_entities_with(
		["XPRewardComponent", "PickedUpComponent"],
		["DeadComponent"]
	)

	if picked.is_empty():
		return

	var players := get_entities_with(
		["PlayerComponent", "LevelComponent", "XPMultComponent"],
		["DeadComponent"]
	)

	if players.is_empty():
		return

	var player_count := players.size()

	for orb_id in picked:
		var reward := cs.get_component(orb_id, "XPRewardComponent")
		if not reward:
			continue

		var base_xp :float= reward.final_value / float(player_count)

		for pid in players:
			var lvl := cs.get_component(pid, "LevelComponent")
			var mult := cs.get_component(pid, "XPMultComponent")

			lvl.current_xp += base_xp * mult.final_value

		cs.add_component(orb_id, "DeadComponent", DeadComponent.new())
