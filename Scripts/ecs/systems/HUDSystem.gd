extends BaseSystem
class_name  HUDSystem


func update(delta: float) -> void:
	var entities = get_entities_with(["HUDComponent"])
	for e_id in entities:
		var current_hp = cs.get_component(e_id,"CurrentHpComponent")
		var max_hp = cs.get_component(e_id,"MaxHpComponent")

		
		if current_hp and max_hp:
			UIManager.hud.current_hp = current_hp.final_value
			UIManager.hud.max_hp = max_hp.final_value
		
		
		
