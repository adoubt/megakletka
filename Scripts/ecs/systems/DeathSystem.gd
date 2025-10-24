extends BaseSystem
class_name DeathSystem



func update(_delta: float):
	var entities = get_entities_with(["CurrentHpComponent"])
	for e_id in entities:
		var hp = cs.get_component(e_id, "CurrentHpComponent")
		if hp.final_value <= 0 and not cs.has_component(e_id, "DeadComponent"):
			cs.add_component(e_id, "DeadComponent", DeadComponent.new())
			print(e_id, " just died")
	
