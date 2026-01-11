extends BaseSystem
class_name DeathSystem


func update(_delta: float):
	var entities = get_entities_with(["CurrentHpComponent"],["DeadComponent", "RespawnableComponent"])
	for e_id in entities:
		var hp = cs.get_component(e_id, "CurrentHpComponent")
		if hp.final_value > 0:
			continue
		
		cs.add_component(e_id, "DeadComponent", DeadComponent.new(0.0))
		var pos: Vector3 = cs.get_component(e_id,"TransformComponent").position
		if cs.has_component(e_id,"PlayerComponent"): 
			var death_frame: int = Engine.get_process_frames()
			cs.add_component(e_id, "RespawnableComponent", RespawnableComponent.new(death_frame))
			cs.get_component(e_id, "RenderComponent").instance.death_anim.play("grave_on")
			cs.get_component(e_id, "RenderComponent").instance.hide_level_up()
			event_bus.emit("player_died",{"e_id": e_id,"position": pos})
		
		if cs.has_component(e_id,"EnemyComponent"): 
			event_bus.emit("enemy_died",{"e_id": e_id,"position": pos})
			
			var xp_reward = cs.get_component(e_id,"XPRewardComponent")
			if xp_reward:
				event_bus.emit("create_xp",[{"e_id": e_id,"position": pos, "xp_value": xp_reward.final_value }])
				
		print(e_id, " just died")
