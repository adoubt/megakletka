extends BaseSystem
class_name  HUDSystem



func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)


	event_bus.subscribe("level_up_offer_created", _on_level_up_offer_created)
	event_bus.subscribe("level_up_panel_toggled", _on_level_up_panel_toggled)
	
func update(delta: float) -> void:
	var entities = get_entities_with(["HUDComponent"])
	for e_id in entities:
		var current_hp = cs.get_component(e_id,"CurrentHpComponent")
		var max_hp = cs.get_component(e_id,"MaxHpComponent")

		
		if current_hp and max_hp:
			UIManager.hud.current_hp = current_hp.final_value
			UIManager.hud.max_hp = max_hp.final_value
		
func _on_level_up_offer_created(callback_data: Dictionary):
		
	
	UIManager.level_up_panel.setup_background(callback_data["offer"])

func _on_level_up_panel_toggled()-> void:
	var entities = get_entities_with(["LevelUpOfferComponent"])
	for entity_id in entities:
		var owner_id = cs.get_component(entity_id,"LevelUpOfferComponent").owner_id
		var instance = cs.get_component(owner_id, "RenderComponent").instance
		if not instance: 
			continue	
		if UIManager.is_panel_open("LevelUpPanel"):
			instance.hide_level_up() 
		else:
			instance.show_level_up()
			
	
			
		
