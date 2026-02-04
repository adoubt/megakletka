extends BaseSystem
class_name HealthSystem

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)
	arch = cs.register_archetype(["CurrentHPRatioComponent","HPChangeRequestComponent", "CurrentHPComponent", "MaxHPComponent","TransformComponent"],["DeadComponent"])
		
func update(_delta: float):
	var entities = arch.entities.duplicate()
	for e_id in entities:
		var request = cs.get_component(e_id, "HPChangeRequestComponent")
		var hp = cs.get_component(e_id, "CurrentHPComponent")
		if abs(request.value) < 0.001:
			cs.remove_component(e_id, "HPChangeRequestComponent")
			continue

		var hp_before = hp.base_value
		var max_hp = cs.get_component(e_id, "MaxHPComponent")
		hp.base_value = clamp(hp.base_value + request.value, 0.0, max_hp.final_value)
		
		cs.get_component(e_id, "CurrentHPRatioComponent").base_value = hp.base_value /max_hp.final_value
		if hp.base_value <= 0.0:
			cs.add_component(e_id, "DeathRequestComponent", DeathRequestComponent.new(request.source_id))
		var diff = hp_before - hp.base_value
		
		if diff < 0.0:
			print(e_id," (", hp.base_value, ") got ",diff," heal " ) 
		else:
			print(e_id," (", hp.base_value, ") got ",diff," damage " ) 
			if cs.has_component(e_id, "EnemyComponent"): 
				cs.add_component(e_id, "HitFlashComponent", HitFlashComponent.new())
				
				var owner_tf = cs.get_component(e_id, "TransformComponent")
				event_bus.emit("damage_done", [{"position": owner_tf.position, "owner_id": e_id, "damage": diff, "damage_type": "physics"}])
				event_bus.emit("enemy_hitted", {"position": owner_tf.position, "e_id": e_id})
			
		event_bus.emit("hp_changed",{"e_id":e_id, "current_hp":hp.base_value, "max_hp": max_hp.final_value})
			

		cs.remove_component(e_id, "HPChangeRequestComponent")
