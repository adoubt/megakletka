extends BaseSystem
class_name HealthSystem

func update(_delta: float):
	var entities = get_entities_with(["PendingHealthComponent", "CurrentHpComponent"],["DeadComponent"])
	for e_id in entities:
		var ph = cs.get_component(e_id, "PendingHealthComponent")
		var hp = cs.get_component(e_id, "CurrentHpComponent")
		if ph == null or hp == null:
			continue

		var hp_before = hp.final_value

		hp.final_value = min(cs.get_component(e_id, "MaxHpComponent").final_value, hp.final_value + ph.amount)
		var heath_done =  hp.final_value - hp_before
		
		print(e_id," (", hp_before, ") got ", heath_done) 
		
		## ✅ Чистим буфер урона
		cs.remove_component(e_id, "PendingHealthComponent")
