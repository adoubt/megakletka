extends BaseSystem
class_name DamageSystem

func update(_delta: float):
	var entities = get_entities_with(["PendingDamageComponent", "CurrentHpComponent"],["DeadComponent"])
	for e_id in entities:
		var pd = cs.get_component(e_id, "PendingDamageComponent")
		var hp = cs.get_component(e_id, "CurrentHpComponent")
		if pd == null or hp == null:
			continue

		var hp_before = hp.final_value

		# Execute (критический удар)
		if pd.execute_chance > 0 and randf() < pd.execute_chance:
			hp.final_value = 0
		else:
			hp.final_value = max(0.0, hp.final_value - pd.amount)
		var damage_done = hp_before - hp.final_value
		if  damage_done > 0.0:
			if cs.has_component(e_id, "EnemyComponent"): 
				if not cs.has_component(e_id, "HitFlashComponent"):
					cs.add_component(e_id, "HitFlashComponent", HitFlashComponent.new())
				
				var owner_tf = cs.get_component(e_id, "TransformComponent")
				event_bus.emit("damage_done", [{"position": owner_tf.position, "owner_id": e_id, "damage": damage_done, "damage_type": "base_hit"}])
				event_bus.emit("enemy_hitted", {"position": owner_tf.position, "e_id": e_id})
			
		print(e_id," (", hp_before, ") took ", damage_done, " dmg from ", pd.source_id) 
		
			
		
		# ✅ Чистим буфер урона
		cs.remove_component(e_id, "PendingDamageComponent")
