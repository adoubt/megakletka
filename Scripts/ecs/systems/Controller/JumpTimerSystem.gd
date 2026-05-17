extends BaseSystem
class_name JumpTimerSystem


func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus,):
	super._init( _entity_manager, _component_store, _event_bus)
	arch = cs.register_archetype([
		"JumpTimerComponent",
	], ["DeadComponent"])
	
func update(_delta):
	var entities:= arch.entities.duplicate()
	for e in entities:
		var timer := cs.get_component(e, "JumpTimerComponent")
		timer.time_left -=_delta
		if timer.time_left <=0:
			cs.remove_component(e, "JumpTimerComponent")
