extends BaseSystem
class_name HitVFXSystem

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)
	arch = cs.register_archetype(["HitVFXComponent","RenderComponent"], ["DeadComponent"])
	
func update(_delta:float) -> void:
	for e in arch.entities:
		
		var hit_vfx = cs.get_component(e,"HitVFXComponent")
		
		if not hit_vfx.started: 
			var instance = cs.get_component(e,"RenderComponent").instance
			if instance: 
				instance.shot()
				hit_vfx.started = true
			
		
			
