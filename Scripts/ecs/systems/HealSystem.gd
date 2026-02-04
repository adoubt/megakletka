extends BaseSystem
class_name HealSystem

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)
	arch = cs.register_archetype(["PendingHealComponent", "CurrentHPComponent","MaxHPComponent"],["DeadComponent"])

	
func update(_delta: float):
	var entities = arch.entities.duplicate()
	for e_id in  entities:
		var ph = cs.get_component(e_id, "PendingHealComponent")
		var hp = cs.get_component(e_id, "CurrentHPComponent")
		if ph == null or hp == null:
			continue

		var hp_before = hp.final_value
		var max_hp = cs.get_component(e_id, "MaxHPComponent").final_value
		hp.final_value = clamp(hp.final_value + ph.amount,0.0, max_hp)
		var heath_done =  hp.final_value - hp_before
		
		print(e_id," (", hp_before, ") got ", heath_done) 
		if heath_done!= 0.0:
			event_bus.emit("hp_changed",{"e_id":e_id, "current_hp":hp.final_value, "max_hp": max_hp})
			
		cs.remove_component(e_id, "PendingHealComponent")
