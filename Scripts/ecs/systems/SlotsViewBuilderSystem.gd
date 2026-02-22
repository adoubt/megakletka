extends BaseSystem
class_name SlotsViewBuilderSystem

func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus):
	super._init( _entity_manager, _component_store, _event_bus)
	arch = cs.register_archetype(["RenderComponent", "SlotsViewBuilderRequestComponent"])
func update(_delta: float) -> void:
	var entities = arch.entities.duplicate()

	for e in entities:
		var render = cs.get_component(e, "RenderComponent")
		if not render or not render.instance:
			continue
		var req = cs.get_component(e, "SlotsViewBuilderRequestComponent")
		
		render.instance.slots_root.rebuild_slots(e, req.slot_states)
		cs.remove_component(e, "SlotsViewBuilderRequestComponent")
