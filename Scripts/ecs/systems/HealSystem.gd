extends BaseSystem
class_name HealSystem

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)
	arch = cs.register_archetype(["PendingHealComponent"],["DeadComponent"])

	
func update(_delta: float):
	var entities = arch.entities.duplicate()
	for e_id in  entities:
		var ph = cs.get_component(e_id, "PendingHealComponent")
		
		if ph.amount > 0.0:
			cs.add_component(
				e_id,
				"HPChangeRequestComponent",
				HPChangeRequestComponent.new(ph.amount, ph.source_id)
			)
		
			
		cs.remove_component(e_id, "PendingHealComponent")
