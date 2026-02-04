extends BaseSystem
class_name PierceSystem

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,  _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)

	arch = cs.register_archetype(["PierceComponent", "ProjectileComponent"],["DeadComponent"])	
	
func update(_delta: float) ->void :
	var projectiles = arch.entities.duplicate()
	for e_id in projectiles:
		var pierce = cs.get_component(e_id, "PierceComponent")
		if pierce.final_value < 0:
			cs.add_component(e_id, "DeadComponent", DeadComponent.new())
	
