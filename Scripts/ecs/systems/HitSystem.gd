extends BaseSystem
class_name HitSystem

func update(delta: float):
	var entities = get_entities_with(["HitComponent", "CurrentHpComponent"],["DeadComponent"])
	for entity_id in entities:
		var hit = cs.get_component(entity_id, "HitComponent")

		# создаём PendingDamage, если его нет
		if not cs.has_component(entity_id, "PendingDamageComponent"):
			cs.add_component(entity_id, "PendingDamageComponent", PendingDamageComponent.new())
			
			
		var pd = cs.get_component(entity_id, "PendingDamageComponent")
		var dmg_comp = cs.get_component(hit.source_id, "DamageComponent")
		if dmg_comp:
			pd.amount = dmg_comp.final_value
		
		var owner = cs.get_component(hit.source_id, "ProjectileComponent")
		if owner:
			if cs.get_component(owner.owner_id, "LifestealComponent") and dmg_comp.final_value > 0:
				var pending_health = cs.get_component(owner.owner_id, "LifestealComponent").final_value * dmg_comp.final_value
				cs.add_component(owner.owner_id, "PendingHealthComponent", PendingHealthComponent.new(pending_health))
		
		
		cs.remove_component(entity_id, "HitComponent")
		
