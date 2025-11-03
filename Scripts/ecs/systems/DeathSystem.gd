extends BaseSystem
class_name DeathSystem


func update(_delta: float):
	var entities = get_entities_with(["CurrentHpComponent"])
	for e_id in entities:
		var hp = cs.get_component(e_id, "CurrentHpComponent")
		if hp.final_value <= 0 and not cs.has_component(e_id, "DeadComponent"):
			cs.add_component(e_id, "DeadComponent", DeadComponent.new())
			var pos: Vector3 = cs.get_component(e_id,"TransformComponent").position
			var exp_reward = cs.get_component(e_id,"ExpRewardComponent")
			if exp_reward:
				var exp_id = em.create_entity()
				cs.add_component(exp_id,"TransformComponent", TransformComponent.new(pos))
				cs.add_component(exp_id,"ExpRewardComponent",ExpRewardComponent.new(exp_reward.final_value))
				cs.add_component(exp_id,"RenderComponent", RenderComponent.new("uid://dosmechqhf3sw"))
				cs.add_component(exp_id,"PickUpComponent", PickUpComponent.new())
			print(e_id, " just died")
