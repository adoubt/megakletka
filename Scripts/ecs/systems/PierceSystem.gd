extends BaseSystem
class_name PierceSystem

func update(_delta: float) ->void :
	var projectiles := get_entities_with(["PierceComponent", "ProjectileComponent"],["DeadComponent"])
	for e_id in projectiles:
		var pierce = cs.get_component(e_id, "PierceComponent")
		if pierce.final_value < 0:
			cs.add_component(e_id, "DeadComponent", DeadComponent.new())
	
