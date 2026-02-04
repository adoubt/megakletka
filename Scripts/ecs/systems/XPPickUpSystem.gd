extends BaseSystem
class_name XPPickUpSystem

var player_arch: Archetype

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus) 
	arch = cs.register_archetype(["XPRewardComponent","PickedUpComponent"])	
	player_arch = cs.register_archetype(["CurrentXPComponent", "XPGainComponent"],
		["DeadComponent"])
		
func update(_delta: float) -> void:
	
	var orbs = arch.entities.duplicate()
	if orbs.is_empty():
		return


	if player_arch.entities.is_empty():
		return

	var player_count := player_arch.entities.size()

	for orb_id in orbs:
		var reward := cs.get_component(orb_id, "XPRewardComponent")
		if not reward:
			continue

		var base_xp :float= reward.final_value / float(player_count)

		for pid in player_arch.entities:
			
			var xp_gain :float = cs.get_component(pid, "XPGainComponent").final_value
			var current_xp = cs.get_component(pid, "CurrentXPComponent")
			current_xp.base_value += base_xp * xp_gain
			event_bus.emit("xp_changed", {"e_id": pid, "current_xp": current_xp.base_value})
		cs.add_component(orb_id, "DeadComponent", DeadComponent.new(0.0))
