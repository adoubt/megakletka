extends BaseSystem
class_name HitSystem

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)
	arch = cs.register_archetype(["HitComponent"],["DeadComponent","PendingDamageComponent"])
	
func update(_delta: float):
	var hits = arch.entities.duplicate()
	for entity_id in hits:
		var hit = cs.get_component(entity_id, "HitComponent")
		var dmg_comp = cs.get_component(hit.source_id, "DamageComponent")
		if dmg_comp:
			cs.add_component(entity_id, "PendingDamageComponent", PendingDamageComponent.new(dmg_comp.final_value, hit.source_id ))
		
		var pierce = cs.get_component(hit.source_id, "PierceComponent")
		if pierce: 
			pierce.base_value -= 1
			
		cs.remove_component(entity_id, "HitComponent")
		
		
		
		

		
		
		
