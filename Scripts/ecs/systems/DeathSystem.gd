extends BaseSystem
class_name DeathSystem

func update(_delta: float) -> void:
	var entities = get_entities_with(["HealthComponent"])
	
	for entity_id in entities:
		var health = cs.get_component(entity_id, "HealthComponent")
		if health == null:
			continue
		
		if health.current_hp <= 0.0:
			# Можно вызвать анимацию смерти или событие
			cs.add_component(entity_id, "DeadComponent", DeadComponent.new())

		
