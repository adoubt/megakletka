extends BaseSystem
class_name JumpsUsedResetSystem

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus) 
	arch = cs.register_archetype(["DirtyStatsComponent","JumpsCountComponent","JumpsLeftComponent","JumpsUsedComponent",])	

func update(_delta:float) -> void:
	for e in arch.entities:
		var left = cs.get_component(e,"JumpsLeftComponent")
		var count = cs.get_component(e, "JumpsCountComponent")
		var used = cs.get_component(e, "JumpsUsedComponent")
		used.base_value = count.final_value - left.base_value
		
