extends BaseSystem
class_name HealthSystem

func update(delta: float):
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
		
		var owner_tf = cs.get_component(e_id, "TransformComponent")
		#var popup_entity = em.create_entity()
		#cs.add_component(popup_entity, "DamagePopupComponent",DamagePopupComponent.new(damage_done,"physical",e_id,owner_tf.position))
		#cs.add_component(popup_entity, "TransformComponent", TransformComponent.new(owner_tf.position))
		#cs.add_component(popup_entity, "RenderComponent",RenderComponent.new("res://Scenes/Popups/DamagePopup.tscn"))
		#cs.add_component(popup_entity, "LifetimeComponent",LifetimeComponent.new(1.0))
#
		## ✅ Чистим буфер урона
		cs.remove_component(e_id, "PendingHealthComponent")
