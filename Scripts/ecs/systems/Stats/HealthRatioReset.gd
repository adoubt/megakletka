extends BaseSystem
class_name HealthRatioReset
func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus) 
	arch = cs.register_archetype(["CurrentHPRatioComponent","MaxHPComponent","CurrentHPComponent"])	

func update(_delta:float) -> void:
	for e in arch.entities:
		var ratio = cs.get_component(e,"CurrentHPRatioComponent")
		var max_hp = cs.get_component(e, "MaxHPComponent")
		var current_hp= cs.get_component(e, "CurrentHPComponent")
		
		var new_ratio: float = current_hp.base_value / max_hp.final_value
		
		if new_ratio != ratio.base_value:
			current_hp.base_value =  max_hp.final_value * ratio.base_value
			
			
			event_bus.emit("hp_changed", {"e_id": e, "current_hp":current_hp.base_value, "max_hp": max_hp.final_value })
