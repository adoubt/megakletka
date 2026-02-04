extends BaseSystem
class_name ResetStatsSystem

func _init(_em, _cs, _bus):
	super._init(_em, _cs, _bus)
	arch = cs.register_archetype(
		["DirtyStatsComponent"],["DeadComponent"]
	)

func update(_delta):
	for e_id in arch.entities:
		for comp_name in Stats.get_all_player_components():
			var comp = cs.get_component(e_id, comp_name)
			if comp:
				comp.final_value = comp.base_value
