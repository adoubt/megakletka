extends BaseSystem
class_name LifeTimeSystem

func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus,):
	super._init( _entity_manager, _component_store, _event_bus)
	arch = cs.register_archetype(["LifeTimeComponent"], ["DeadComponent"])
func update(delta: float) -> void:
	var entities = arch.entities.duplicate()
	for e in entities:
		var life_time = cs.get_component(e, "LifeTimeComponent")
		life_time.time_left -= delta
		if life_time.time_left <= 0.0:
			cs.add_component(e, "DeadComponent", DeadComponent.new())
		
