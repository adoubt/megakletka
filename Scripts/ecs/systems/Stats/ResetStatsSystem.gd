extends BaseSystem
class_name ResetStatsSystem

func _init(_em, _cs, _bus):
	super._init(_em, _cs, _bus)
	arch = cs.register_archetype(
		["HasStatsComponent"],
		["DeadComponent"]
	)

func update(_delta):
	for e_id in arch.entities:
		for comp_name in StatsRegistry.STAT_COMPONENTS:
			var comp = cs.get_component(e_id, comp_name)
			if comp != null:
				comp.final_value = comp.base_value
