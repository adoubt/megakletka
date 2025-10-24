extends BaseSystem
class_name DamageSystem

func update(delta: float):
	var entities = get_entities_with(["PendingDamageComponent","CurrentHpComponent"])
	for e_id in entities:
		var pd = cs.get_component(e_id,"PendingDamageComponent")
		var current_hp = cs.get_component(e_id,"CurrentHpComponent")
		if pd == null or current_hp == null:
			continue
		var _current_hp_before = current_hp.final_value
		# Execute
		if pd.execute_chance > 0 and randi()%100 < int(pd.execute_chance*100):
			current_hp.final_value = 0
		else:
			
			current_hp.final_value = min(0.0, current_hp.final_value - pd.amount)
		print(e_id, " got ", current_hp.final_value - _current_hp_before," dmg from ",pd.source_id)
		# удаляем PendingDamage после применения
		cs.remove_component(e_id,"PendingDamageComponent")
