extends BaseSystem
class_name LifeTimeSystem

func update(delta: float) -> void:
	var entities = get_entities_with(["LifeTimeComponent"], ["DeadComponent"])
	for e in entities:
		var life_time = cs.get_component(e, "LifeTimeComponent")
		
		if life_time.time_left <= 0.0:
			cs.add_component(e, "DeadComponent", DeadComponent.new())
		life_time.time_left -= delta
