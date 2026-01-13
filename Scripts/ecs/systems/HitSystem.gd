extends BaseSystem
class_name HitSystem


func update(delta: float):
	var entities = get_entities_with(["HitComponent", "CurrentHpComponent"],["DeadComponent"])
	for entity_id in entities:
		var hit = cs.get_component(entity_id, "HitComponent")
	
		## Create PendingDamage if not exist
		if not cs.has_component(entity_id, "PendingDamageComponent"):
			cs.add_component(entity_id, "PendingDamageComponent", PendingDamageComponent.new())
			
			
		var pd = cs.get_component(entity_id, "PendingDamageComponent")
		var dmg_comp = cs.get_component(hit.source_id, "DamageComponent")
		if dmg_comp:
			pd.amount = dmg_comp.final_value
		
		var owner = cs.get_component(hit.source_id, "ProjectileComponent")
		## BullShit. I can't steal hp if an enemy blocked all the damage in its system. So it's a bad palce for lifesteal//// 
		if owner:
			if cs.get_component(owner.owner_id, "LifestealComponent") and dmg_comp.final_value > 0:
				var pending_health = cs.get_component(owner.owner_id, "LifestealComponent").final_value * dmg_comp.final_value
				cs.add_component(owner.owner_id, "PendingHealthComponent", PendingHealthComponent.new(pending_health))
			var pierce = cs.get_component(hit.source_id, "PierceComponent")
			if pierce: 
				pierce.final_value -= 1

		
		cs.remove_component(entity_id, "HitComponent")
		
