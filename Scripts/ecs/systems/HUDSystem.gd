extends BaseSystem
class_name  HUDSystem


func update(delta: float) -> void:
	var entities = get_entities_with(["HUDComponent"])
	for e_id in entities:
		var current_hp = cs.get_component(e_id,"CurrentHpComponent")
		var max_hp = cs.get_component(e_id,"MaxHpComponent")
		var current_exp = cs.get_component(e_id, "CurrentExpComponent")
		
		if current_hp and max_hp :
			UIManager.hud.value = current_hp.final_value
			UIManager.hud.max_value = max_hp.final_value
		if current_exp:
			UIManager.hud.current_exp
		var enemies = get_entities_with(["TeamComponent"])
		UIManager.dev_panel.enemies_count.text ="Enemies: "+ str(enemies.size())
		var projectiles = get_entities_with(["ProjectileComponent"],["DeadComponent"]) 
		UIManager.dev_panel.projectiles_count.text = "Projectiles: "+str(projectiles.size())
		
