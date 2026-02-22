extends BaseSystem
class_name StatModifierOverrideSystem


func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus ):
	super._init(_entity_manager, _component_store, _event_bus)
	
	arch = cs.register_archetype(["ItemViewBuildRequestComponent","ItemComponent", "RenderComponent",],["DeadComponent"])

func update(delta: float) -> void:
	if arch.entities.is_empty():
		return
