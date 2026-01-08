extends BaseSystem
class_name StatsRecalculationSystem

func update(_delta: float) -> void:
	
	var players = get_entities_with(["PlayerComponent"],["DeadComponent"])
	for player in players:
		cs.get_component(player,"ProjectileCountComponent").final_value = cs.get_component(player,"ProjectileCountComponent").base_value
		cs.get_component(player,"CurrentHpRatioComponent").final_value = cs.get_component(player,"CurrentHpComponent").final_value / cs.get_component(player,"MaxHpComponent").final_value
		cs.get_component(player,"DamageComponent").final_value = cs.get_component(player,"DamageComponent").base_value
		cs.get_component(player,"MaxHpComponent").final_value = cs.get_component(player,"MaxHpComponent").base_value
		cs.get_component(player,"CurrentHpComponent").base_value = cs.get_component(player,"CurrentHpComponent").final_value
		cs.get_component(player,"LifestealComponent").final_value = cs.get_component(player,"LifestealComponent").base_value
		cs.get_component(player,"XPPickUpRangeComponent").final_value = cs.get_component(player,"XPPickUpRangeComponent").base_value
		cs.get_component(player,"AttackSpeedComponent").final_value = cs.get_component(player,"AttackSpeedComponent").base_value
		cs.get_component(player,"ProjectileRadiusComponent").final_value = cs.get_component(player,"ProjectileRadiusComponent").base_value
		cs.get_component(player,"WeaponRadiusComponent").final_value = cs.get_component(player,"WeaponRadiusComponent").base_value
		cs.get_component(player,"ProjectileSpeedComponent").final_value = cs.get_component(player,"ProjectileSpeedComponent").base_value
		
		
	var items = get_entities_with(["ItemComponent"],["DeadComponent"])
	for item in items:
		var owner_id = cs.get_component(item,"ItemComponent").owner_id
		if cs.has_component(owner_id,"DeadComponent"):
			continue 
		var proj_count = cs.get_component(item,"ProjectileCountComponent")
		if proj_count:
			cs.get_component(owner_id,"ProjectileCountComponent").final_value = cs.get_component(owner_id,"ProjectileCountComponent").final_value + proj_count.final_value
		
		var proj_speed = cs.get_component(item,"ProjectileSpeedComponent")
		if proj_speed:
					cs.get_component(owner_id,"ProjectileSpeedComponent").final_value = cs.get_component(owner_id,"ProjectileSpeedComponent").final_value + proj_speed.final_value
		
		var weapon_radius = cs.get_component(item,"WeaponRadiusComponent")
		if weapon_radius:
			cs.get_component(owner_id,"WeaponRadiusComponent").final_value = cs.get_component(owner_id,"WeaponRadiusComponent").final_value + weapon_radius.final_value
		
		var proj_radius = cs.get_component(item,"ProjectileRadiusComponent")
		if proj_radius:
			cs.get_component(owner_id,"ProjectileRadiusComponent").final_value = cs.get_component(owner_id,"ProjectileRadiusComponent").final_value + proj_radius.final_value
		
		var attack_speed = cs.get_component(item,"AttackSpeedComponent")
		if attack_speed:
			cs.get_component(owner_id,"AttackSpeedComponent").final_value = cs.get_component(owner_id,"AttackSpeedComponent").final_value + attack_speed.final_value
		
		var xp_pick_up_range = cs.get_component(item,"XPPickUpRangeComponent")
		if xp_pick_up_range:
			cs.get_component(owner_id,"XPPickUpRangeComponent").final_value = cs.get_component(owner_id,"XPPickUpRangeComponent").final_value + xp_pick_up_range.final_value
		
		var damage = cs.get_component(item,"DamageComponent")
		if damage:
			cs.get_component(owner_id,"DamageComponent").final_value = cs.get_component(owner_id,"DamageComponent").final_value + damage.final_value
		
		var max_hp = cs.get_component(item,"MaxHpComponent")
		if max_hp:
			cs.get_component(owner_id,"MaxHpComponent").final_value = cs.get_component(owner_id,"MaxHpComponent").final_value + max_hp.final_value
		
		
		var max_hp_mult = cs.get_component(item,"MaxHpMultComponent")
		if max_hp_mult:	
			var max_hp_before = cs.get_component(owner_id,"MaxHpComponent").final_value
			var max_hp_after = max_hp_before * max_hp_mult.final_value
			cs.get_component(owner_id,"MaxHpComponent").final_value = max_hp_after
			
			cs.get_component(owner_id,"CurrentHpComponent").final_value = cs.get_component(owner_id,"MaxHpComponent").final_value * cs.get_component(owner_id,"CurrentHpRatioComponent").final_value
			
			#cs.get_component(owner_id,"CurrentHpComponent").final_value = 
			
		
		var lifesteal = cs.get_component(item,"LifestealComponent")
		if lifesteal:
			cs.get_component(owner_id,"LifestealComponent").final_value += lifesteal.final_value
			
			
