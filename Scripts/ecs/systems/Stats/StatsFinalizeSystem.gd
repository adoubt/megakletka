extends BaseSystem
class_name StatFinalizeSystem


func _init(_em, _cs, _bus):
	super._init(_em, _cs, _bus)
	arch = cs.register_archetype(["DirtyStatsComponent"])

func update(_delta):
	var entities = arch.entities.duplicate()
	for e in entities:
		var snapshot = _build_snapshot(e)
		if cs.get_component(e, "PlayerComponent"):
			
			event_bus.emit("stats_snapshot_ready", {
				"entity": e,
				"snapshot": snapshot
			})
			
		elif cs.get_component(e,"ItemComponent"):
			cs.add_component(e, "ItemViewBuildRequestComponent", ItemViewBuildRequestComponent.new())
		cs.remove_component(e, "DirtyStatsComponent")
		
func _build_snapshot(e: int) -> Dictionary:
	var snapshot := {}

	for stat_id in Stats.PlayerStats.values():
		var value := _get_stat_value(e, stat_id)
		snapshot[Stats.PlayerStats.values()[stat_id]] = snapped(value, 0.1)

	return snapshot
	
func _get_stat_value(entity_id: int,  stat: int) -> float:
	

	var comp_name := Stats.get_comp_name(Stats.Domain.PLAYER, stat)
	if comp_name == "":
		return 0.0	
	var comp = cs.get_component(entity_id, comp_name)
	if comp == null:
		return 0.0

	return comp.final_value
